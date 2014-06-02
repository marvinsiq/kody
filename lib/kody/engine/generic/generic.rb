require 'fileutils'
require 'liquid'
require 'kody/modules'
require 'kody/string'
require 'kody/properties'
require 'kody/builder/class_builder'
require 'kody/builder/project_builder'
require 'kody/engine/demoiselle/datatype'


# TODO
class Generic

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

	def generate
		@entities.each do |e|			
			generate_class(e)
		end
	end

	private
	def initialize_builders
		App.logger.info "Initializing builders..."

		@entities = Array.new
		@enumerations = Array.new

		@model.classes.each do |clazz|
			initialize_class(clazz)
		end		

		App.logger.info "Builders initialized"
	end

	private
	def initialize_package(package)	
		
		#App.logger.debug "Package: #{package.name}"	
		package.classes.sort.each do |c|
			initialize_class(c)
		end
		
		package.packages.sort.each do |p|
			initialize_package(p)
		end
	end	

	private
	def initialize_class(clazz)
		
		#App.logger.debug "Class: #{clazz.name}"		
		class_builder = ClassBuilder.new(clazz, self)

		case class_builder.stereotype
		when :entity
			@entities << class_builder
		when :enumeration
			@enumerations << class_builder
		else
			return
		end		
	end

	private
	def generate_class(clazz)
	
		@hash['class'] = clazz
		generate_classes(clazz)
		generate_dao(clazz)
	end

	private
	def load_template(template_name)
		@templates = Hash.new if @templates.nil?
		return @templates[template_name] if !(@templates[template_name]).nil?		

		full_template_name = File.expand_path File.dirname(__FILE__) + "/templates/" + template_name
		arquivo_template = File.read(full_template_name)
		template = Liquid::Template.parse(arquivo_template)
		Liquid::Template.register_filter(TextFilter)

		@templates[template_name] = template

		App.logger.info "Template '#{template_name}' loaded..."

		return template
	end

	private
	def generate_classes(clazz)

		case clazz.stereotype
		when :entity			
			template = load_template("entity.tpl")
		when :enumeration
			template = load_template("enumeration.tpl")
		else
			return
		end

		@rendered = template.render(@hash)
		path = output + "/src/main/java/" + clazz.package.gsub(".", "/") + "/"	
		file_name = clazz.name + ".java"
		save(@rendered, path, file_name)		
	end	

	private
	
	def save(content, path, file_name)	
		FileUtils.mkdir_p(path) unless File.exists?(path)
		
		file = File.new("#{path}#{file_name}", "w")
		file.write(content)
		file.close

		App.logger.debug "Template saved in #{path}#{file_name}"
	end

end
