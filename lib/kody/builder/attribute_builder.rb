require 'kody/string'

class AttributeBuilder

	attr_reader :type
	attr_reader :imports

	def initialize(attribute, class_builder, engine)
		@attribute = attribute
		@engine = engine

		@imports = Array.new		

		@type = engine.convert_type(@attribute.type)

		@visibility = @attribute.visibility
		
		@multiplicity_range = @attribute.multiplicity_range
		
		@clazz = class_builder.name

		if @type == "String"
			@initial_value = "\"#{@attribute.initial_value}\""
		else
			@initial_value = "#{@attribute.initial_value}"
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

		if @attribute.is_enum?

			type_enum = "varchar"

			if !@attribute.enum_obj.nil? && @attribute.enum_obj.attributes.size > 0
				t =  engine.convert_type(@attribute.enum_obj.attributes[0].type)
				if t == "Integer"
					type_enum = "integer"
				end
			end

			@annotations << "@Column(name=\"#{column_name}\", columnDefinition=\"#{type_enum}\")"
			@annotations << "@Type(type = \"br.gov.mp.siconv.GenericEnumUserType\", parameters = { @Parameter(name = \"enumClass\", value = \"#{@type}\") })"

			@imports << "org.hibernate.annotations.Parameter"
			@imports << "org.hibernate.annotations.Type"		
		else
			@annotations << "@Column(name=\"#{column_name}\")"
		end

		@attribute.tagged_values.each do |t|
			@comment = t.value if "@andromda.persistence.comment" == t.name
			@length = t.value if "@andromda.persistence.column.length" == t.name
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
	  	'visibility' => 'public'
	  }
	end

end