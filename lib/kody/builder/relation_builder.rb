

class Relation

	attr_reader :annotations
	attr_reader :imports	

	# UmlAssociationEnd
	def initialize(uml_class_from, uml_association_end, model, type, nullable = true)
		
		@type = type
		@nullable = nullable

		@name = uml_association_end.name
		@fetch = nil
		
		@visibility = uml_association_end.visibility
		@visibility = "private" if @visibility.empty?

    	participant = model.find_recursive_class_by_id(uml_association_end.participant)
    	@uml_class_name_to = participant.name unless participant.nil?

    	@name = @uml_class_name_to.lower_camel_case if @name.empty? && !@uml_class_name_to.nil?

    	@annotations = Array.new
    	@imports = Array.new

		class_to_under = @uml_class_name_to.underscore
		class_from_under = uml_class_from.name.underscore    	

    	case type
    	
    	when "OneToOne"
    		@att_type = @uml_class_name_to 

		when "ManyToOne"
			@join_column_name = "#{@name}_fk"
			@att_type = @uml_class_name_to
			@target_entity = "#{@uml_class_name_to}.class" 

			@annotations << "@ManyToOne(targetEntity=#{@uml_class_name_to}.class)"
			@annotations << "@JoinColumn(name = \"#{class_to_under}_fk\", nullable = #{@nullable})"

			@imports << "javax.persistence.ManyToOne"
			@imports << "javax.persistence.JoinColumn"			

		when "OneToMany"
			@att_type = "List<#{@uml_class_name_to}>"
			@initialize = " = new ArrayList<#{@uml_class_name_to}>()"

			@annotations << '@OneToMany(mappedBy="' + class_from_under + '")'
    		@imports << "javax.persistence.OneToMany"			
			@imports << "java.util.ArrayList"
			@imports << "java.util.List"

		when "ManyToMany"
			@att_type = "List<#{@uml_class_name_to}>"
			@initialize = " = new ArrayList<#{@uml_class_name_to}>()"
			@imports << "java.util.ArrayList"
			@imports << "java.util.List"

			if uml_association_end.first
				join_table =  "#{class_to_under}_#{class_from_under}"		
			else				
				join_table =  "#{class_from_under}_#{class_to_under}"
			end

			join_column = "#{class_from_under}_fk"
			inverse_join_column = "#{class_to_under}_fk"	

			@annotations << "@ManyToMany(targetEntity=#{@uml_class_name_to}.class)"
			@annotations << '@JoinTable(name = "' + 
				join_table + '", joinColumns = { @JoinColumn(name = "' + 
				join_column + '") }, inverseJoinColumns = { @JoinColumn(name = "' + 
				inverse_join_column + '") })'

			@imports << "javax.persistence.ManyToMany"
			@imports << "javax.persistence.JoinTable"
			@imports << "javax.persistence.JoinColumn"

    	end

    	uml_association_end.tagged_values.each do |t|
			#puts "Tag: " + t.name + ", " + t.value

			case t.name
			when '@andromda.hibernate.cascade'
				@cascade = Datatype.cascade(t.value)

			when '@andromda.hibernate.orderByColumns'
				@imports << "javax.persistence.OrderBy"
				@annotations << '@OrderBy("' + t.value + '")'
			end
		end 
	end


	def to_liquid
		{
		'annotations'=>@annotations,
		'att_type'=>@att_type,
		'name'=>@name,
		'initialize'=>@initialize,
		'visibility'=>@visibility,	   
		'uml_class_to'=>@uml_class_name_to,
		'type'=>@type
		}
	end	

end