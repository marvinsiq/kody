# encoding: utf-8

require 'kody/builder/builder'

class ControllerBuilder < Builder

	attr_accessor :name
	attr_accessor :package
	attr_accessor :operations
	attr_accessor :parameters
	attr_accessor :abstract
	attr_accessor :extends
	attr_accessor :initial_operation

	def initialize
		@parameters = Array.new	
		@operations = Array.new
		@abstract = false
	end

	def to_liquid
	  {
	  	'name'=> @name,
	  	'parameters' => @parameters,
	  	'operations' => @operations,
	  	'package' => @package
	  }
	end		
	
end