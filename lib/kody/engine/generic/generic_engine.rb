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
			@properties = Properties.load(@output)
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

	
	end

	def convert_type(type)
		Datatype.java_type(type)
	end	

end