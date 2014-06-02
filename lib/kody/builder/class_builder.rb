# encoding: utf-8

require 'kody/builder/attribute_builder'
require 'kody/string'

class ClassBuilder

	attr_reader :stereotype
	attr_reader :name
	attr_reader :package
	attr_reader :persistence_package
	attr_reader :business_package
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

		@persistence_package = engine.properties["project.persistence.package"];
		raise "Property 'project.persistence.package' does not exists in #{App.specification.name}.properties." if @persistence_package.nil?
		@business_package = engine.properties["project.business.package"]
		raise "Property 'project.business.package' does not exists in #{App.specification.name}.properties." if @business_package.nil?

		@enum_type = "String"

		@attributes = Array.new
		@clazz.attributes.each do |a|
			att = AttributeBuilder.new(a, self, engine)
			@attributes << att
			@imports = @imports + att.imports
			@enum_type = att.type
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
			puts "Possui heranca #{@name }- #{@clazz.parent}"			
			@clazz.parent.tagged_values.each do |t|	
				puts "Tags '#{t.name}' = '#{t.value}'"			
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
		
		@clazz.stereotypes.each do |s|
			case s.name
			when "org.andromda.profile::persistence::Entity", 
				"UML Standard Profile::entity",
				"Entity"
				@stereotype = :entity				
			when "org.andromda.profile::persistence::WebServiceData"
				@stereotype = :web_service_data
			when "org.andromda.profile::ApplicationException"
				@stereotype = :application_exception
			when "org.andromda.profile::Enumeration"
				@stereotype = :enumeration
			when "org.andromda.profile::presentation::FrontEndSessionObject"
				@stereotype = :front_end_session_object
			when "org.andromda.profile::ValueObject"
				@stereotype = :value_object
			else
				App.logger.warn "Stereotype desconhecido: '#{s.name}', classe: #{clazz.name}"	
			end
		end

		@imports = @imports.uniq.sort
	end

	def to_liquid
	  {
	  	'annotations' => @annotations,
	  	'attributes' => @attributes,
	  	'business_package' => @business_package,
	  	'extends' => @extends,
	  	'enum_type' => @enum_type,
	  	'name'=> @name,
	  	'imports' => @imports,
	  	'package' => @package,
	  	'persistence_package' => @persistence_package,
	  	'relations' => relations,
	  	'table_name' => table_name,
	  	'sequence_name' => sequence_name
	  }
	end

	def relations
		Array.new
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
		@table_name = @table_name[0, 30]
		@table_name
	end

	def sequence_name
		"#{table_name}_seq"
	end

end