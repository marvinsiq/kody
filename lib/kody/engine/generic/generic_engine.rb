require 'fileutils'
require 'liquid'
require 'kody/modules'
require 'kody/string'
require 'kody/properties'
require 'kody/builder/class_builder'
require 'kody/builder/project_builder'
require 'kody/engine/demoiselle/datatype'


class GenericEngine < Engine

	attr_accessor :output
	attr_accessor :model
	attr_accessor :properties

	def initialize(model=nil)
		@output = Dir.pwd
		@hash = Hash.new	

		@model = model
		if !model.nil?

			properties_filename = "#{App.specification.name}.properties"
			properties_path = "#{@output}/#{properties_filename}"
			App.logger.info "Loading project property file #{properties_filename}..."
			
			@properties = Properties.load(properties_path)
			initialize_builders			
		end
	end

	def initialize(model, properties)
		@output = Dir.pwd
		@hash = Hash.new	
		@properties = properties
		@model = model
		if !model.nil?
			initialize_builders			
		end		
	end

	def name
		return "Generic"
	end

	def version
		return "1.0"
	end

	def generate_template(template_path, output)
		
		template = load_template_path(template_path)

		@classes.each do |class_builder|
			@hash['class'] = class_builder
			@rendered = template.render(@hash).strip
			next if @rendered.empty?

			path = output + "/" + class_builder.package.gsub(".", "/") + "/"
			file_name = class_builder.name + ".java"
			save(@rendered, path, file_name)				
		end

		@use_cases.each do |use_case|
			@hash['use_case'] = use_case
			@rendered = template.render(@hash).strip
			next if @rendered.empty?

			path = output + "#{use_case.name}/"
			file_name = use_case.name.underscore + ".xhtml"
			save(@rendered, path, file_name)
		end
	
	end

	def convert_type(type)
		Datatype.java_type(type)
	end	

end
