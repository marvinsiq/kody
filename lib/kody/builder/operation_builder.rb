# encoding: utf-8

require 'kody/builder/builder'

class OperationBuilder < Builder

	def initialize(operation, class_builder, engine)
		
		@engine = engine

		@name = operation.name
		@visibility = "public" #operation.visibility
		@return_type = "void"

		@imports = Array.new	
	end	

	def to_liquid
	  {
	  	'name'=> @name,
	  	'return_type' => @return_type,
	  	'visibility' => @visibility
	  }
	end

end