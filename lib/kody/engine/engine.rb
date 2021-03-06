require 'fileutils'
require 'liquid'
require 'kody/modules'
require 'kody/string'
require 'kody/properties'
require 'kody/builder/class_builder'
require 'kody/builder/project_builder'
require 'kody/builder/use_case_builder'
require 'kody/engine/demoiselle/datatype'

class Engine

	def initialize
		@classes = Array.new
		@entities = Array.new
		@enumerations = Array.new
		@use_cases = Array.new
	end

	def save(content, path, file_name = nil, overwrite = true)
		
		if (file_name.nil?)	
			full_file_name = path
		else
			FileUtils.mkdir_p(path) unless File.exists?(path)
			full_file_name = "#{path}/#{file_name}"
		end

		if !overwrite && File.exist?(full_file_name)
			#App.logger.warn "File #{full_file_name} exists."		
			return
		end

		file = File.new(full_file_name, "w")
		file.write(content)
		file.close

		App.logger.info "File saved in #{full_file_name}"		
	end	

	def load_template_path(full_template_name)

		@templates = Hash.new if @templates.nil?
		return @templates[full_template_name] if !(@templates[full_template_name]).nil?	

		arquivo_template = File.read(full_template_name)
		template = Liquid::Template.parse(arquivo_template)
		Liquid::Template.register_filter(TextFilter)

		@templates[full_template_name] = template

		App.logger.debug "Template '#{full_template_name}' loaded..."

		return template
	end

	protected
	def initialize_builders(model)		

		model.classes.each do |clazz|
			initialize_class(clazz)
		end

		model.enumerations.each do |enumeration|
			initialize_enumeration(enumeration)
		end

		model.use_cases.each do |use_case|
			initialize_use_cases(use_case)
		end		

		App.logger.info "Builders initialized for model '#{model.model_file_name}'"
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

	def initialize_enumeration(enumeration)
		class_builder = ClassBuilder.new(enumeration, self)
		@classes << class_builder
		@enumerations << class_builder	
	end

	def initialize_use_cases(use_case)
		use_case_builder = UseCaseBuilder.new(use_case, self)
		@use_cases << use_case_builder
	end

end