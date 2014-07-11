require 'fileutils'
require 'liquid'
require 'kody/modules'
require 'kody/string'
require 'kody/properties'
require 'kody/builder/class_builder'
require 'kody/builder/project_builder'
require 'kody/engine/demoiselle/datatype'

class Engine

	def save(content, path, file_name = nil)
		
		if (file_name.nil?)	
			full_file_name = path
		else
			FileUtils.mkdir_p(path) unless File.exists?(path)
			full_file_name = "#{path}#{file_name}"
		end

		file = File.new(full_file_name, "w")
		file.write(content)
		file.close

		App.logger.info "File saved in #{full_file_name}"		
	end	

	def load_template(template_name)
		full_template_name = File.expand_path File.dirname(__FILE__) + "/templates/" + template_name
		load_template_path(full_template_name)
	end

	def load_template_path(full_template_name)

		@templates = Hash.new if @templates.nil?
		return @templates[full_template_name] if !(@templates[full_template_name]).nil?	

		arquivo_template = File.read(full_template_name)
		template = Liquid::Template.parse(arquivo_template)
		Liquid::Template.register_filter(TextFilter)

		@templates[full_template_name] = template

		App.logger.info "Template '#{full_template_name}' loaded..."

		return template
	end

	protected
	def initialize_builders
		App.logger.info "Initializing builders..."

		@classes = Array.new
		@entities = Array.new
		@enumerations = Array.new

		@model.classes.each do |clazz|
			initialize_class(clazz)
		end		

		App.logger.info "Builders initialized"
	end

	##
	# @param [Clazz, #read] clazz	
	def initialize_class(clazz)
		
		#App.logger.debug "Class: #{clazz.name}"		
		class_builder = ClassBuilder.new(clazz, self)
		@classes << class_builder
		case class_builder.stereotype
		when :entity
			@entities << class_builder
		when :enumeration
			@enumerations << class_builder
		else
			return
		end		
	end	

end