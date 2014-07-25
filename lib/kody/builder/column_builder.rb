# encoding: utf-8

require 'kody/builder/builder'

class ColumnBuilder < Builder

	attr_accessor :name
	attr_accessor :property_key
	attr_accessor :property_value

	def initialize(name, field)		
		@field = field
		self.name = name
	end	

	def name=(name)		
		@name = name
		@property_key = @field.property_key + "." + @name.property_key		
		@property_value = @name.capitalize_all
	end

	def name
		@name
	end		

	def to_liquid
	  {
	  	'name'=> @name,
	  	'property_key' => @property_key,
	  	'property_value' => @property_value
	  }
	end
end