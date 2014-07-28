require 'kody/string'

class AttributeBuilder

	attr_accessor :name
	attr_accessor :type
	attr_accessor :imports

	def initialize(attribute=nil, class_builder=nil, engine=nil)

		return if attribute.nil?

		@attribute = attribute
		@engine = engine

		@imports = Array.new		

		@type = engine.convert_type(@attribute.type)

		@visibility = @attribute.visibility
		
		@multiplicity_range = @attribute.multiplicity_range
		
		nullable = ''
		nullable = ', nullable=false' if @multiplicity_range == [1, 1]
		
		@clazz = class_builder.name unless class_builder.nil?

		@initial_value = ""
		if !@attribute.initial_value.empty?
			if @type == "String"
				@initial_value = "\"#{@attribute.initial_value}\""
			else
				@initial_value = "#{@attribute.initial_value}"
			end
		end

		#@stereotypes = @attribute.stereotypes
		#@tagged_values = @attribute.tagged_values

		@name = @attribute.name.strip
		@name.gsub!(/[ -]/, "_")

		column_name = @name.underscore[0, 30]

		@annotations = Array.new		

		if @type.eql?("java.util.Date")
			if @attribute.type.include?("DateTime") || @attribute.type.include?("Timestamp")
				@annotations << "@Temporal(TemporalType.TIMESTAMP)"
			elsif @attribute.type.include? "Time"
				@annotations << "@Temporal(TemporalType.TIME)"
			else
				@annotations << "@Temporal(TemporalType.DATE)"
			end
			@imports << "javax.persistence.Temporal"
			@imports << "javax.persistence.TemporalType"
		end

		@length = ""
		@unique = ""
		@attribute.tagged_values.each do |t|
		
			case t.name
				when "@andromda.persistence.comment"
					@comment = t.value
				when "@length", "@andromda.persistence.column.length"
					@length = ", length=#{t.value}"
				when "@unique"
					@unique = ", unique=#{t.value}"
			end
		end		

		if @attribute.is_enum?

			column_definition = ", columnDefinition=\"varchar\""

			@enum_type = "String"

			if !@attribute.enum_obj.nil? && @attribute.enum_obj.attributes.size > 0
				t =  engine.convert_type(@attribute.enum_obj.attributes[0].type)
				@enum_type = t
				if t == "Integer"
					column_definition = ", columnDefinition=\"integer\""
				end
			end

			# FIXME
			#column_definition = ""

			@annotations << "@Column(name=\"#{column_name}\"#{nullable}#{@length}#{@unique})"

			#@annotations << "@Column(name=\"#{column_name}\"#{column_definition}#{nullable})"
			#@annotations << "@Type(type = \"GenericEnumUserType\", parameters = { @Parameter(name = \"enumClass\", value = \"#{@type}\") })"
			#@annotations << "@Enumerated(EnumType.STRING)"

			#@imports << "org.hibernate.annotations.Parameter"
			#@imports << "org.hibernate.annotations.Type"	

			#@imports << "javax.persistence.EnumType"
			#@imports << "javax.persistence.Enumerated"
		else
			@annotations << "@Column(name=\"#{column_name}\"#{nullable}#{@length}#{@unique})"
		end
	end

	def to_liquid
	  {
	  	'annotations' => @annotations,
	  	'name'=> @name,
	  	'comment' => @comment,
	  	'initial_value' => @initial_value,
	  	'length' => @length,
	  	'type' => @type,
	  	'visibility' => 'public',
	  	'is_enum' => @attribute.is_enum?,
	  	'enum_type' => @enum_type
	  }
	end

end