
class FieldBuilder
	
	attr_accessor :name
	attr_accessor :type
	attr_accessor :size

	def initialize(parameter)
		@name = parameter.name.camel_case
		@type = "text"
		parameter.tagged_values.each do |tagged_value|

		case tagged_value.name 
		when "@andromda.presentation.web.view.field.size"
			@size = tagged_value.value
		when "@andromda.presentation.web.view.field.size"
			@type = tagged_value.value
		end

		end
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
	  	'type'=> @type,
	  	'size'=> @size
	  }
	end
end