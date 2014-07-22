# encoding: utf-8

require 'kody/builder/builder'

class PageBuilder < Builder

	attr_accessor :name
	attr_accessor :fields
	attr_accessor :controller

	def initialize
		@fields = Array.new
	end

	def to_liquid
	  {
	  	'name'=> @name,
	  	'fields' => @fields,
	  	'controller' => @controller
	  }
	end	
end