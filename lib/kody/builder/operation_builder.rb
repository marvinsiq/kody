# encoding: utf-8

require 'kody/builder/builder'

class OperationBuilder < Builder

	attr_accessor :name	
	attr_accessor :return_type
	attr_accessor :visibility

	def initialize(operation=nil, engine=nil)
	
		@engine = engine
		
		@visibility = "public" #operation.visibility
		@return_type = "void"

		@imports = Array.new

		return if operation.nil?
		@name = operation.name
	end	

	def to_liquid
	  {
	  	'name'=> @name,
	  	'return_type' => @return_type,
	  	'visibility' => @visibility
	  }
	end

end