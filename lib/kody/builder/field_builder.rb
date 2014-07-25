# encoding: utf-8

require 'kody/builder/builder'
require 'kody/builder/column_builder'

class FieldBuilder
	
	attr_accessor :type
	attr_accessor :size
	attr_accessor :columns
	attr_accessor :actions
	attr_accessor :property_key
	attr_accessor :property_value

	def initialize(parameter, page)
		@page = page
		self.name = parameter.name.camel_case.uncapitalize
		@type = "text"
		
		@columns = Array.new
		@actions = Array.new

		@is_table = false

		parameter.tagged_values.each do |tagged_value|

			case tagged_value.name 
			when "@andromda.presentation.web.view.field.size"
				@size = tagged_value.value
			when "@andromda.presentation.web.view.field.type"
				@type = tagged_value.value
			when "@andromda.presentation.view.table.columns"
				if !tagged_value.value.empty?
					columns = tagged_value.value.split(",")
					columns.each do |column|
						@columns << ColumnBuilder.new(column, self)
					end
				end
			when "@andromda.presentation.view.table"
				@is_table = tagged_value.value	
			end

		end		
	end

	def name=(name)		
		@name = name
		@property_key = @page.name.property_key + "." + @name.property_key		
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
	  	'actions' => @actions,
	  	'name'=> name,
	  	'type'=> @type,
	  	'size'=> @size,
	  	'columns' => @columns,
	  	'is_table' => @is_table,
	  	'property_key'	 => @property_key
	  }
	end
end