# encoding: utf-8

require 'kody/builder/builder'
require 'kody/builder/page_builder'
require 'kody/builder/controller_builder'
require 'kody/builder/field_builder'
require 'kody/builder/parameter_builder'

class UseCaseBuilder < Builder

	attr_reader :name
	attr_reader :pages
	attr_reader :controllers

	def initialize(use_case, engine)
		@name = use_case.name

		@pages = Array.new
		@controllers = Array.new

		use_case.activity_graphs.each do |activity_graph|
			activity_graph.states.each do |state|
				state.stereotypes.each do |stereotype|
					if stereotype.name.to_s == "org.andromda.profile::presentation::FrontEndView"

						name = @name.camel_case.capitalize_first + state.name.camel_case.capitalize_first

						page = PageBuilder.new
						@pages << page
						page.name = name

						controller = ControllerBuilder.new
						@controllers << controller
						controller.name = name + "MB"

						page.controller = controller

						# Itera sobre as transições para pegar os parâmetros e métodos
						state.targets.each do |target|

							# Se a transição possui uma trigger (signal, call)
							if !target.from_transition.trigger.nil?

								# Se o Action state possui um deferrable_event, ou seja, está ligado a um método de uma classe
								if target.is_action_state? && !target.deferrable_event.nil? && !target.deferrable_event.operation.nil?
									operation = OperationBuilder.new(target.deferrable_event.operation, engine)
								else
									operation = OperationBuilder.new
									operation.name = target.from_transition.trigger.name
								end
								controller.operations << operation							

								target.from_transition.trigger.parameters.each do |parameter|									
									
									field = FieldBuilder.new(parameter)
									parameter = ParameterBuilder.new(parameter, engine)
																
									controller.parameters << parameter unless controller.parameters.include? parameter
									page.fields << field unless page.fields.include? field
								end
							end
						end
					end
				end
			end
		end
	end

	def to_liquid
	  {
	  	'name'=> @name
	  }
	end

end