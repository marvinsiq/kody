# encoding: utf-8

require 'kody/builder/builder'

class OperationBuilder < Builder

	attr_accessor :return_type
	attr_accessor :visibility
	attr_accessor :parameters
	attr_accessor :content
	attr_accessor :property_key
	attr_accessor :property_value	
	attr_accessor :initial
	attr_accessor :calls

	def initialize(operation=nil, engine=nil)
	
		@engine = engine
		
		@visibility = "public" #operation.visibility
		@return_type = "String"

		@imports = Array.new
		@parameters = Array.new
		@calls = Array.new

		@content = ""

		@initial = false

		return if operation.nil?
		self.name = operation.name.camel_case.uncapitalize
	end

	def name=(name)		
		@name = name
		@property_key = @name.property_key		
		@property_value = @name.capitalize_all
	end

	def name
		@name
	end

	def <=>(obj)
    	@name <=> obj.name
	end

	def ==(obj)
		return false if obj.nil?
		if String == obj.class
			@name == obj
		else
    		@name == obj.name
    	end
	end	

	def to_liquid
	  {
	  	'name'=> @name,
	  	'return_type' => @return_type,
	  	'visibility' => @visibility,
	  	'content' => @content,
	  	'property_key' => @property_key
	  }
	end

end