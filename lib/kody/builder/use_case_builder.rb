# encoding: utf-8

require 'kody/builder/builder'
require 'kody/builder/controller_builder'
#require 'kody/builder/column_builder'
require 'kody/builder/field_builder'
require 'kody/builder/page_builder'
require 'kody/builder/parameter_builder'

class State
	def checked=(checked)
		@checked = checked
	end
	def checked?
		@checked
	end
end

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
			init_state(activity_graph.initial_state)
			#activity_graph.states.each do |state|
			#	init_state(state)
			#end
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

	def init_state(state, page=nil, controller=nil)

		App.logger.debug "State '#{state.name}'"

		state.checked? ? return : state.checked = true
	
		if state.is_initial_state?
			if !state.targets.nil?

				state = state.targets[0]

				page = PageBuilder.new
				@index_page = page
				@pages << page
				page.name = @name

				controller = ControllerBuilder.new
				@controllers << controller
				controller.name = @name.removeaccents.camel_case + "MB"
				abstract_controller = ControllerBuilder.new
				@controllers << abstract_controller
				abstract_controller.name = @name.removeaccents.camel_case + "AbstractMB"
				abstract_controller.abstract = true
				controller.extends = abstract_controller

				operation = OperationBuilder.new
				operation.name = "init"
				operation.return_type = "void"
				operation.initial = true

				controller.operations << operation

				controller.initial_operation = operation

				page.controller = controller

				init_state(state, page, controller)
			
			end
		
		elsif state.is_decision_point?

			state.targets.each do |target|
				init_state(target, page, controller)
			end			
		
		elsif state.is_action_state?

			if state.stereotypes.include?("FrontEndView") || state.stereotypes.include?("org.andromda.profile::presentation::FrontEndView")

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

				# Itera sobre as transições de entrada do State para verificar os campos necessários da tela
				state.from_transitions.each do |from_transition|
					if !from_transition.trigger.nil?				
						from_transition.trigger.parameters.each do |parameter|

							field = FieldBuilder.new(parameter, page)
							parameter = ParameterBuilder.new(parameter, controller, @engine)
														
							controller.parameters << parameter unless controller.parameters.include? parameter
							page.fields << field unless page.fields.include? field

							App.logger.debug "Controle '#{controller.name}' - Parametro de entrada: #{parameter.name}. Tela #{name}"
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

						operation = check_operation(controller, target, transition.trigger.name.removeaccents.camel_case.uncapitalize)

						# Itera sobre os parâmetros do método da transição para cria-los na classe de controle e tela
						transition.trigger.parameters.each do |p|			
														
							parameter = ParameterBuilder.new(p, controller, @engine)														
							controller.parameters << parameter unless controller.parameters.include? parameter

							# Se a tela não possui uma tabela o parâmetro será um campo
							if tablelink.nil?
								field = FieldBuilder.new(p, page)
								page.fields << field unless page.fields.include? field
							
							# Caso contrário o parâmetro será um parâmetro da action que passará para a próxima view
							else
								operation.parameters << parameter
							end

							App.logger.debug "Controle '#{controller.name}' - Parametro do metodo '#{operation.name}' para '#{name}': #{parameter.name}"
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
			
			else

				operation = check_operation(controller, state, state.name.removeaccents.camel_case.uncapitalize)				

				# Itera sobre as transições de entrada do State para verificar os campos necessários da tela
				state.from_transitions.each do |from_transition|
					if !from_transition.trigger.nil?				
						from_transition.trigger.parameters.each do |parameter|

							parameter = ParameterBuilder.new(parameter, controller, @engine)
														
							controller.parameters << parameter unless controller.parameters.include? parameter

							App.logger.debug "Controle '#{controller.name}' - Parametro de entrada para '#{operation.name}': #{parameter.name}"
						end	
					end			
				end

				# Itera sobre as transições para pegar os parâmetros e métodos
				state.transitions.each do |transition|

					target = transition.target

					# Se a transição possui uma trigger (signal, call)
					if !transition.trigger.nil?

						if transition.trigger.class == SignalEvent

							if transition.trigger.name.nil? or transition.trigger.name.empty?
								operation_name = transition.target.name.removeaccents.camel_case.uncapitalize
							else
								operation_name = transition.trigger.name.removeaccents.camel_case.uncapitalize
							end
						
							parameters = transition.trigger.parameters

						elsif transition.trigger.class == CallEvent
							operation_name = transition.trigger.operation.name.removeaccents.camel_case.uncapitalize

							parameters = transition.trigger.operation.parameters
						end

						operation = check_operation(controller, target, operation_name)			

						# Itera sobre os parâmetros do método da transição para cria-los na classe de controle
						parameters.each do |p|			
							
							if p.kind == "return"
								operation.return_type = @engine.convert_type(p.type)

							elsif !p.name.nil? && !p.name.empty?
								parameter = ParameterBuilder.new(p, controller, @engine)														
								controller.parameters << parameter unless controller.parameters.include? parameter

								operation.parameters << parameter						

								App.logger.debug "\tControle '#{controller.name}' - Parametro do metodo '#{operation.name}' para Action '#{target.name}': #{parameter.name}"
							end
						end unless parameters.nil?
					end

					init_state(transition.target, page, controller)
				end	
			end
		end
	end

	def check_operation(controller, state, name) 

		if state.is_action_state?

			if !state.targets.empty? && state.targets.size == 1

				target = state.targets[0]
				if target.is_action_state? && target.stereotypes.include?("FrontEndView") || state.stereotypes.include?("org.andromda.profile::presentation::FrontEndView")
					App.logger.info "State '#{state.name}' será entrada da tela '#{target.name}'"
					return
				end

			end

		end
		
		# Se o Action state possui um deferrable_event, ou seja, está ligado a um método de uma classe
		if state.is_action_state? && !state.deferrable_event.nil? && !state.deferrable_event.operation.nil?
			operation = OperationBuilder.new(state.deferrable_event.operation, @engine)
		else
			operation = OperationBuilder.new
			operation.name = name
		end

		operation_return = nil
		
		if state.is_final_state?
			# TODO: Pegar o nome da primeira FrontendView do próximo caso de uso
			operation_return = "\"" + state.name.hyphenate + "?faces-redirect=true\""
		end
		
		if operation_return.nil? && state.targets.size == 1	
			
			if state.targets[0].is_decision_point?

				# transição de entrada 
				if state.targets[0].from_transitions.size == 1

					from_transition = state.targets[0].from_transitions[0]

					if !from_transition.trigger.nil? && !from_transition.trigger.operation.nil?						
						decision_operation = OperationBuilder.new(from_transition.trigger.operation, @engine)
						decision_operation.content += "return null;"

						App.logger.debug "\tControle '#{controller.name}' - Metodo decision de '#{state.targets[0].name}': #{decision_operation.name}"

						controller.operations << decision_operation unless controller.operations.include? decision_operation			
						operation.content = "String r = #{decision_operation.name}();\n"
					end
					
					state.targets[0].transitions.each do |transition|
						
						method = transition.target.name.removeaccents.camel_case.uncapitalize + "()"
						if transition.target.is_action_state? && !transition.target.deferrable_event.nil? && !transition.target.deferrable_event.operation.nil?
							target_operation = OperationBuilder.new(transition.target.deferrable_event.operation, @engine)
							method = target_operation.name + "()"
						end						

						operation.content += "\t\tif (r == \"#{transition.guard_condition}\") {\n"
						operation.content += "\t\t\treturn #{method};\n"
						operation.content += "\t\t}\n"
					end

				end	

				operation.content += "\t\treturn null;"				

			else
				# Se o próximo state da FrontendView possuir apenas uma transição e não for um decision point, este state será a página que será redirecionada
				operation_return = "\"" + generate_page_name(state.targets[0]).hyphenate + "?faces-redirect=true\""
			end
		end
		unless operation_return.nil?
			operation_return = "\"\"" if operation_return.nil?
			operation.content = "return #{operation_return};"
		end

		App.logger.debug "\tControle '#{controller.name}' - Metodo de '#{state.name}': #{operation.name}"

		controller.operations << operation unless controller.operations.include? operation

		controller.initial_operation.calls << operation

		return operation
	end		

end