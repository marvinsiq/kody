# encoding: utf-8

require 'kody/builder/builder'
require 'kody/builder/controller_builder'
#require 'kody/builder/column_builder'
require 'kody/builder/field_builder'
require 'kody/builder/page_builder'
require 'kody/builder/parameter_builder'

class UseCaseBuilder < Builder

	attr_reader :name
	attr_reader :pages
	attr_reader :controllers

	def initialize(use_case, engine)
		@name = use_case.name
		@engine = engine

		@pages = Array.new
		@controllers = Array.new

		@index_page = nil
		use_case.activity_graphs.each do |activity_graph|
			activity_graph.states.each do |state|
				init_state(state)
			end
		end
	end

	def to_liquid
	  {
	  	'name'=> @name
	  }
	end

	private

	def generate_page_name(state)
		return @name.removeaccents.camel_case + state.name.removeaccents.camel_case
	end

	def init_state(state)
		
		if state.stereotypes.include? "org.andromda.profile::presentation::FrontEndView"

			name = generate_page_name(state)

			page = PageBuilder.new
			@pages << page
			page.name = name

			controller = ControllerBuilder.new
			@controllers << controller
			controller.name = name + "MB"

			page.controller = controller

			# Se esta for a primeira página o nome da página e do controle será o nome do caso de uso e não do "state"
			if @index_page.nil?
				@index_page = page
				page.name = @name
				controller.name = @name.removeaccents.camel_case + "MB"
			end			

			# Itera sobre as trnsições de entrada do State para verificar os campos necessários da tela
			state.from_transitions.each do |from_transition|
				if !from_transition.trigger.nil?				
					from_transition.trigger.parameters.each do |parameter|

						field = FieldBuilder.new(parameter, page)
						parameter = ParameterBuilder.new(parameter, @engine)
													
						controller.parameters << parameter unless controller.parameters.include? parameter
						page.fields << field unless page.fields.include? field
					end	
				end			
			end

			# Itera sobre as transições para pegar os parâmetros e métodos
			state.transitions.each do |transition|

				target = transition.target

				tablelink = nil
				transition.tagged_values.each do |tagged_value|
					case tagged_value.name 
					when "@andromda.presentation.web.action.tablelink"
						# indica que a ação será executada de dentro de uma tabela
						# cada item da tabela terá um botão
						tablelink = tagged_value.value
					end
				end	

				if !tablelink.nil?
					# Busca o field com esse nome
					index = page.fields.index(tablelink)
					if index.nil?
						App.logger.warn "Não encontrou o campo '#{tablelink}' definido como uma tabela na página '#{page.name}'."
					else
						field_tablelink = page.fields[index]
					end
				end

				# Se a transição possui uma trigger (signal, call)
				if !transition.trigger.nil?

					# Se o próximo state da FrontendView possuir apenas uma transição, este state será a página que será redirecionada
					operation_return = nil
					if target.is_final_state?
						# TODO: Pegar o nome da primeira FrontendView do próximo caso de uso
						operation_return = "\"" + target.name.hyphenate + "?faces-redirect=true\""
					end					
					if operation_return.nil? && target.targets.size == 1						
						operation_return = "\"" + generate_page_name(target.targets[0]).hyphenate + "?faces-redirect=true\""
					end				

					# Se o Action state possui um deferrable_event, ou seja, está ligado a um método de uma classe
					if target.is_action_state? && !target.deferrable_event.nil? && !target.deferrable_event.operation.nil?
						operation = OperationBuilder.new(target.deferrable_event.operation, @engine)
					else
						operation = OperationBuilder.new
						operation.name = transition.trigger.name.removeaccents.camel_case.uncapitalize
					end
					operation_return = "\"\"" if operation_return.nil?
					operation.content = "return #{operation_return};"
					
					controller.operations << operation unless controller.operations.include? operation

					# Itera sobre os parâmetros do método da transição para cria-los na classe de controle e tela
					transition.trigger.parameters.each do |p|			
													
						parameter = ParameterBuilder.new(p, @engine)														
						controller.parameters << parameter unless controller.parameters.include? parameter

						# Se a tela não possui uma tabela o parâmetro será um campo
						if tablelink.nil?
							field = FieldBuilder.new(p, page)
							page.fields << field unless page.fields.include? field
						
						# Caso contrário o parâmetro será um parâmetro da action que passará para a próxima view
						else
							operation.parameters << parameter
						end
					end

					# Se não possui uma tabela a operação será um botão na página
					if tablelink.nil? || (!tablelink.nil? && field_tablelink.nil?)
						page.actions << operation unless page.actions.include? operation
					else
						# se possui uma tabela, a ação será um botão para cada item da tabela
						field_tablelink.actions << operation unless field_tablelink.actions.include? operation
					end										

				end
			end		
		end
	end

end