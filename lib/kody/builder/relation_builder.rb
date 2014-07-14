

class Relation

	attr_reader :annotations
	attr_reader :imports	

	# UmlAssociationEnd
	def initialize(uml_association_end, class_builder, engine)
		
		other_end = uml_association_end.other_end
		
		multiplicity_range_start = other_end.multiplicity_range		
		multiplicity_range_end = uml_association_end.multiplicity_range

		#puts "multiplicity_range_start: #{multiplicity_range_start}"
		#puts "multiplicity_range_end: #{multiplicity_range_end}"

		if multiplicity_range_start.nil?
			multiplicity_range_start = [1, 1]
			#App.logger.warn "Multiplicity not defided in relation '#{other_end.association.to_s}'. Side: '#{other_end.participant.full_name}'"
		end

		if multiplicity_range_end.nil?
			multiplicity_range_end = [1, 1]
			#App.logger.warn "Multiplicity not defided in relation '#{other_end.association.to_s}'. Side: '#{uml_association_end.participant.full_name}'"
		end	
		
		if multiplicity_range_start[0] == 0 && multiplicity_range_start[1] == 1

			if multiplicity_range_end[0] == 0 && multiplicity_range_end[1] == 1
				type = "OneToOne"
				nullable = true
			elsif multiplicity_range_end[0] == 1 && multiplicity_range_end[1] == 1
				type = "OneToOne"
				nullable = false		
			elsif multiplicity_range_end[0] == 0 && multiplicity_range_end[1] == -1
				type = "OneToMany"
				nullable = true
			elsif multiplicity_range_end[0] == 1 && multiplicity_range_end[1] == -1
				type = "OneToMany"
				nullable = false
			end

		elsif multiplicity_range_start[0] == 1 && multiplicity_range_start[1] == 1

			if multiplicity_range_end[0] == 0 && multiplicity_range_end[1] == 1
				type = "OneToOne"
				nullable = true
			elsif multiplicity_range_end[0] == 1 && multiplicity_range_end[1] == 1
				type = "OneToOne"
				nullable = false				
			elsif multiplicity_range_end[0] == 0 && multiplicity_range_end[1] == -1
				type = "OneToMany"
				nullable = true
			elsif multiplicity_range_end[0] == 1 && multiplicity_range_end[1] == -1
				type = "OneToMany"
				nullable = false
			end
		
		elsif multiplicity_range_start[0] == 0 && multiplicity_range_start[1] == -1

			if multiplicity_range_end[0] == 0 && multiplicity_range_end[1] == 1
				type = "ManyToOne"
				nullable = true
			elsif multiplicity_range_end[0] == 1 && multiplicity_range_end[1] == 1
				type = "ManyToOne"
				nullable = false		
			elsif multiplicity_range_end[0] == 0 && multiplicity_range_end[1] == -1
				type = "ManyToMany"
				nullable = true
			elsif multiplicity_range_end[0] == 1 && multiplicity_range_end[1] == -1
				type = "ManyToMany"
				nullable = false
			end

		elsif multiplicity_range_start[0] == 1 && multiplicity_range_start[1] == -1

			if multiplicity_range_end[0] == 0 && multiplicity_range_end[1] == 1
				type = "ManyToOne"
				nullable = true
			elsif multiplicity_range_end[0] == 1 && multiplicity_range_end[1] == 1
				type = "ManyToOne"
				nullable = false			
			elsif multiplicity_range_end[0] == 0 && multiplicity_range_end[1] == -1
				type = "ManyToMany"
				nullable = true
			elsif multiplicity_range_end[0] == 1 && multiplicity_range_end[1] == -1
				type = "ManyToMany"
				nullable = false
			end
		end

		@type = type
		@nullable = nullable

		@name = uml_association_end.name
		if @name == "EndA" || @name == "EndB"
    		@name = uml_association_end.participant.name.lower_camel_case
    		if type == "OneToMany" || type == "ManyToMany"
    			@name = @name + "s"
    		end
    	end

		other_end_name = other_end.name
		if other_end_name == "EndA" || other_end_name == "EndB"
			other_end_name = other_end.participant.name.lower_camel_case

    		if type == "ManyToOne" || type == "ManyToMany"
    			other_end_name = other_end_name + "s"
    		end			
		end    	

		@fetch = nil
		
		@visibility = uml_association_end.visibility
		@visibility = "private" if @visibility.empty?

    	participant = uml_association_end.participant
    	
		property_name = class_builder.name.underscore
    	target_class_name = participant.name unless participant.nil?
		target_property_name = target_class_name.underscore		

    	@annotations = Array.new
    	@imports = Array.new

    	@imports << participant.full_name

    	case type
    	
    	when "OneToOne"
    		@att_type = target_class_name 

		when "ManyToOne"
			join_column_name = "#{@name.underscore}_fk"
			@att_type = target_class_name
			@target_entity = "#{target_class_name}.class" 

			@annotations << "@ManyToOne(targetEntity=#{@target_entity})"
			@annotations << "@JoinColumn(name = \"#{join_column_name}\", nullable = #{@nullable})"

			@imports << "javax.persistence.ManyToOne"
			@imports << "javax.persistence.JoinColumn"			

		when "OneToMany"
			@att_type = "List<#{target_class_name}>"
			@initialize = " = new ArrayList<#{target_class_name}>()"

			mappedBy = other_end_name

			@annotations << '@OneToMany(mappedBy="' + mappedBy + '")'
    		@imports << "javax.persistence.OneToMany"			
			@imports << "java.util.ArrayList"
			@imports << "java.util.List"

		when "ManyToMany"
			@att_type = "List<#{target_class_name}>"
			@initialize = " = new ArrayList<#{target_class_name}>()"
			@imports << "java.util.ArrayList"
			@imports << "java.util.List"

			if uml_association_end.is_first
				join_table =  "#{target_property_name}_#{property_name}"		
			else				
				join_table =  "#{property_name}_#{target_property_name}"
			end

			join_column = "#{property_name}_fk"
			inverse_join_column = "#{target_property_name}_fk"	

			@annotations << "@ManyToMany(targetEntity=#{target_class_name}.class)"
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
			#when '@andromda.hibernate.cascade'
			#	@cascade = Datatype.cascade(t.value)

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
		'type'=>@type
		}
	end	

end