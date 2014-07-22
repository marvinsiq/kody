# encoding: utf-8

require 'kody/builder/builder'

class UseCaseBuilder < Builder

	attr_reader :name

	def initialize(use_case, engine)
		@name = use_case.name

		use_case.activity_graphs.each do |activity_graph|
			activity_graph.initial_state		
		end
	end

	def to_liquid
	  {
	  	'name'=> @name
	  }
	end

end