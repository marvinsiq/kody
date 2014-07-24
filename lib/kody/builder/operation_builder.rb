# encoding: utf-8

require 'kody/builder/builder'

class OperationBuilder < Builder

	attr_accessor :name	
	attr_accessor :return_type
	attr_accessor :visibility
	attr_accessor :parameters
	attr_accessor :content

	def initialize(operation=nil, engine=nil)
	
		@engine = engine
		
		@visibility = "public" #operation.visibility
		@return_type = "String"

		@imports = Array.new
		@parameters = Array.new

		return if operation.nil?
		@name = operation.name.camel_case.uncapitalize
	end	

	def to_liquid
	  {
	  	'name'=> @name,
	  	'return_type' => @return_type,
	  	'visibility' => @visibility,
	  	'content' => @content
	  }
	end

end