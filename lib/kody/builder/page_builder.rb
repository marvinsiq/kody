# encoding: utf-8

require 'kody/builder/builder'

class PageBuilder < Builder

	attr_accessor :name
	attr_accessor :fields
	attr_accessor :controller

	# Operation
	attr_accessor :actions

	def initialize
		@fields = Array.new
		@actions = Array.new
	end

	def to_liquid
	  {
	  	'actions' => @actions,
	  	'name'=> @name,
	  	'fields' => @fields,
	  	'controller' => @controller
	  }
	end	
end