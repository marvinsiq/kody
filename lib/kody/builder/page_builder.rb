# encoding: utf-8

require 'kody/builder/builder'

class PageBuilder < Builder

	attr_accessor :fields
	attr_accessor :controller
	attr_accessor :property_key
	attr_accessor :property_value

	# Operation
	attr_accessor :actions

	def initialize
		@fields = Array.new
		@actions = Array.new
	end

	def name=(name)		
		@name = name
		@property_key = @name.property_key		
		@property_value = @name.capitalize_all
	end

	def name
		@name
	end		

	def to_liquid
	  {
	  	'actions' => @actions,
	  	'name'=> @name,
	  	'fields' => @fields,
	  	'controller' => @controller,
	  	'property_key' => @property_key
	  }
	end	
end