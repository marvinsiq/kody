# encoding: utf-8

require 'kody/builder/builder'

class ControllerBuilder < Builder

	attr_accessor :name
	attr_accessor :package
	attr_accessor :operations
	attr_accessor :parameters

	def initialize
		@parameters = Array.new	
		@operations = Array.new
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