# encoding: utf-8

require 'kody/builder/builder'
require 'kody/builder/attribute_builder'
require 'kody/builder/operation_builder'
require 'kody/builder/relation_builder'
require 'kody/string'

class ClassBuilder < Builder

	attr_reader :stereotype
	attr_reader :name
	attr_reader :package
	#attr_reader :persistence_package
	#attr_reader :business_package
	attr_reader :enum_type

	def initialize(clazz, engine)
		@clazz = clazz
		@engine = engine

		@name = @clazz.name.strip
		@package = @clazz.package.full_name
		@table_name = nil

		@extends = @clazz.parent.full_name if !@clazz.parent.nil?
		@annotations = Array.new
		@imports = Array.new

		@enum_type = "String"

		@attributes = Array.new
		@clazz.attributes.each do |a|
			att = AttributeBuilder.new(a, self, engine)
			@attributes << att
			@imports = @imports + att.imports
			@enum_type = att.type
		end

		@relations = Array.new
		@clazz.associations_end.each do |association_end|
			relation = Relation.new(association_end, self, engine)
			if relation.is_navigable
				@relations << relation
				@imports = @imports + relation.imports
			end
		end

		@operations = Array.new
		@clazz.operations.each do |a|
			operation = OperationBuilder.new(a, self, engine)
			@operations << operation
		end

		inheritance = nil

		@clazz.tagged_values.each do |t|
			if "@andromda.persistence.table" == t.name
				@table_name = t.value.downcase[0, 30]
			elsif "@andromda.hibernate.inheritance" == t.name

				# "org.andromda.profile::persistence::HibernateInheritanceStrategy::subclass"
				inheritance = "JOINED"

				if t.value == "org.andromda.profile::persistence::HibernateInheritanceStrategy::class"
					inheritance = "SINGLE_TABLE"
					@annotations << "@DiscriminatorColumn(name=\"class\", discriminatorType=DiscriminatorType.STRING)"
					@imports << "javax.persistence.DiscriminatorColumn"
					@imports << "javax.persistence.DiscriminatorType"
				end			

			elsif "@andromda.hibernate.generator.class" == t.name

			else
				puts "tagged value desconhecida: #{clazz.name} - #{t.name}: #{t.value}"
			end
		end

		# Verifica se esta classe possui filhas.
		# Caso positipo irá tratar a estratégia de herança "JOINED"
		if inheritance.nil? && !@clazz.children.nil? && @clazz.children.size > 0
			inheritance = "JOINED"
		end

		# Verifica se este classe é filha e se a classe pai possui a tagged value @andromda.persistence.inheritance
		if inheritance.nil? && !@clazz.parent.nil?
			#puts "Possui heranca #{@name }- #{@clazz.parent}"			
			@clazz.parent.tagged_values.each do |t|	
				#puts "Tags '#{t.name}' = '#{t.value}'"			
				if "@andromda.persistence.inheritance".eql?(t.name)
					puts 'Chegou aqui'
					if t.value == "org.andromda.profile::persistence::HibernateInheritanceStrategy::class"
						puts 'Chegou aqui 2'
						@annotations << "@DiscriminatorValue(\"#{@clazz.parent.name.strip}\")"
					end
					break
				end
			end
		end		

		if !inheritance.nil?
			@annotations << "@Inheritance(strategy=InheritanceType.#{inheritance})"
			@imports << "javax.persistence.Inheritance"
			@imports << "javax.persistence.InheritanceType"
		end
		
		stereotypes = stereotypes(@clazz)
		@stereotype = stereotypes[0]

		@imports = @imports.uniq.sort
	end

	def to_liquid
	  {
	  	'annotations' => @annotations,
	  	'attributes' => @attributes,
	  	#'business_package' => @business_package,
	  	'extends' => @extends,
	  	'enum_type' => @enum_type,
	  	'name'=> @name,
	  	'operations' => @operations,
	  	'imports' => @imports,
	  	'package' => @package,
	  	#'persistence_package' => @persistence_package,
	  	'relations' => relations,
	  	'stereotype' => @stereotype.to_s,
	  	'table_name' => table_name,
	  	'sequence_name' => sequence_name
	  }
	end

	def relations
		@relations
	end

	def table_name
		return @table_name unless @table_name.nil?
		@table_name = @clazz.name.underscore
		App.abbreviations.each do |k, v|

			@table_name.gsub!(/^#{k}_/, "#{v}_")			
			@table_name.gsub!(/_#{k}_/, "_#{v}_")
			@table_name.gsub!(/_#{k}$/, "_#{v}")
			@table_name.gsub!(/^#{k}$/, "#{v}")

			#puts "#{k} -> #{v} = #{@table_name}"
		end
		#@table_name = @table_name[0, 30]
		@table_name
	end

	def sequence_name
		"#{table_name}_seq"
	end

end