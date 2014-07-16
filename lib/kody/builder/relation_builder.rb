# encoding: utf-8

require 'kody/builder/builder'

class Relation < Builder

	attr_reader :annotations
	attr_reader :imports	
	attr_reader :is_navigable

	# UmlAssociationEnd
	def initialize(uml_association_end, class_builder, engine)
		
		other_end = uml_association_end.other_end

		@is_navigable = uml_association_end.is_navigable

		#App.logger.warn "Associação '#{uml_association_end.association.to_s}' #{uml_association_end.is_navigable} para #{uml_association_end.to_s}"
		#App.logger.warn "Associação '#{other_end.association.to_s}' #{other_end.is_navigable} para #{other_end.to_s}"
		
		multiplicity_range_start = other_end.multiplicity_range		
		multiplicity_range_end = uml_association_end.multiplicity_range

		#App.logger.debug "multiplicity_range_start: #{multiplicity_range_start}"
		#App.logger.debug "multiplicity_range_end: #{multiplicity_range_end}"

		if multiplicity_range_start.nil?
			multiplicity_range_start = [1, 1]
			#App.logger.warn "Multiplicity not defided in relation '#{other_end.association.to_s}'. Side: '#{other_end.participant.full_name}'"
		end

		if multiplicity_range_end.nil?
			multiplicity_range_end = [1, 1]
			#App.logger.warn "Multiplicity not defided in relation '#{other_end.association.to_s}'. Side: '#{uml_association_end.participant.full_name}'"
		end	
		
		from = multiplicity_name(multiplicity_range_start[0], multiplicity_range_start[1])
		to = multiplicity_name(multiplicity_range_end[0], multiplicity_range_end[1])
		type = from[0] + "To" + to[0]
		@type = type
		@nullable = to[1]

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

    	is_enum = false
    	stereotypes = stereotypes(participant)    	
    	if !stereotypes.index(:enumeration).nil?
    		is_enum = true
    		App.logger.debug "Possui relacionamento com enum. #{uml_association_end.association.to_s}"
    	end

    	case @type
    	
    	when "OneToOne"
    		@att_type = target_class_name 

		when "ManyToOne"
			join_column_name = "#{@name.underscore}_fk"
			@att_type = target_class_name

			if !is_enum
				@target_entity = "#{target_class_name}.class" 

				@annotations << "@ManyToOne(targetEntity=#{@target_entity})"
				@annotations << "@JoinColumn(name = \"#{join_column_name}\", nullable = #{@nullable})"

				@imports << "javax.persistence.ManyToOne"
				@imports << "javax.persistence.JoinColumn"			
			end

		when "OneToMany"
			@att_type = "List<#{target_class_name}>"
			@initialize = " = new ArrayList<#{target_class_name}>()"
			
			if !is_enum				

				# Se a relação é unidirecional não usa o mappedBy
				if other_end.is_navigable
					mappedBy = other_end_name
					@annotations << '@OneToMany(mappedBy="' + mappedBy + '")'
				else
					@annotations << '@OneToMany'
				end
	    		@imports << "javax.persistence.OneToMany"			
				@imports << "java.util.ArrayList"
				@imports << "java.util.List"
			end

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

	def multiplicity_name(lower, upper)
		
		name = nil
		nullable = true

		if lower == 0
			
			if upper == 0
				name = "Many"
			elsif upper == 1
				nullable = false	
				name = "One"
			elsif upper == -1
				name = "Many"
			end
		
		elsif lower == 1

			nullable = false
			
			if upper == 0
				name = "One"
			elsif upper == 1
				name = "One"
			elsif upper == -1
				name = "Many"
			end
		
		elsif lower == -1

			nullable = false
			
			if upper == 0
				name = "Many"
			elsif upper == 1
				name = "Many"
			elsif upper == -1
				name = "Many"
			end		
		end	

		return [name, nullable]
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