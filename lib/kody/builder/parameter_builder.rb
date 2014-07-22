require 'kody/string'

class ParameterBuilder

	attr_accessor :name
	attr_accessor :type
	attr_accessor :imports

	def initialize(parameter, engine)

		@parameter = parameter
		@engine = engine

		@imports = Array.new
		@annotations = Array.new		

		@type = engine.convert_type(@parameter.type)
		
		@name = @parameter.name.strip
		@name.gsub!(/[ -]/, "_")

		column_name = @name.underscore[0, 30]

		if @parameter.is_enum?

			type_enum = "varchar"

			if !@parameter.enum_obj.nil? && @parameter.enum_obj.attributes.size > 0
				t =  engine.convert_type(@parameter.enum_obj.attributes[0].type)
				if t == "Integer"
					type_enum = "integer"
				end
			end
		end
	end

	def <=>(obj)
    	@name <=> obj.name
	end

	def ==(obj)
		puts "Passou aqui comparando #{obj}"
		return false if obj.nil?
		if String == obj.class
			@name == obj
		else
    		@name == obj.name
    	end
	end	

	def to_liquid
	  {
	  	'annotations' => @annotations,
	  	'name'=> @name,
	  	'comment' => @comment,
	  	'type' => @type,
	  	'visibility' => 'public'
	  }
	end

end