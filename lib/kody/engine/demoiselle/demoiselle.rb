require 'fileutils'
require 'liquid'
require 'kody/modules'
require 'kody/string'
require 'kody/properties'
require 'kody/builder/class_builder'
require 'kody/builder/project_builder'
require 'kody/engine/demoiselle/datatype'

class Demoiselle

	attr_accessor :output
	attr_accessor :model

	def initialize(model=nil)
		@output = Dir.pwd
		@hash = Hash.new	

		@model = model
		if !model.nil?
			self.properties = Properties.load(@output)
			initialize_builders			
		end
	end

	def initialize(model, _properties)
		@output = Dir.pwd
		@hash = Hash.new	
		self.properties = _properties
		@model = model
		if !model.nil?
			initialize_builders			
		end		
	end

	def properties=(properties)
		@properties = properties
		unless(@properties.nil?)
			@project_files = "#{@output}/project/#{project_name}"
		end
		@properties
	end

	def properties
		@properties
	end

	def name
		return "Java Demoiselle"
	end

	def version
		return @properties["framework_version"]
	end

	def project_name
		return @properties["project.name"]
	end

	# Cria um novo projeto
	def create_project(params)

		#TODO: validar se o projeto existe

		create_dirs(params)
		create_properties_file(params)
		create_maven_project(params)

		App.logger.info "Project #{params[:project_name]} created."		
	end

	def generate
		generate_domain
		generate_enumerations
		generate_businnes
		generate_persistence_xml
	end

	# Gera os Beans e os DAOs
	def generate_domain
		@entities.each do |e|			
			generate_class(e)
		end
	end

	# Gera as enumerações
	def generate_enumerations
		@enumerations.each do |e|
			generate_class(e)
		end	
	end	

	# Gera as classes da camada de negócio baseada nas entidades
	def generate_businnes
		@entities.each do |e|			
			generate_bc(e)
		end		
	end

	# Gera o arquivo de configuração do JPA
	def generate_persistence_xml
		template = load_template("persistence.xml.tpl")
		path = "#{@project_files}/src/main/resources/META-INF/"
		file_name = "persistence.xml"
		rendered = template.render('classes' => @entities)
		save(rendered, path, file_name)
		path = "#{@project_files}/src/test/resources/META-INF/"
		save(rendered, path, file_name)	
	end	

	def convert_type(type)
		Datatype.java_type(type)
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

	def initialize_package(package)	
		
		#App.logger.debug "Package: #{package.name}"	
		package.classes.sort.each do |c|
			initialize_class(c)
		end
		
		package.packages.sort.each do |p|
			initialize_package(p)
		end
	end	

	##
	# @param [Clazz, #read] clazz	
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

	##
	# @param [ClassBuilder, #read] class_builder
	def generate_class(class_builder)
	
		@hash['class'] = class_builder
		generate_classes(class_builder)
		generate_dao(class_builder)
	end

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

	def generate_classes(class_builder)

		case class_builder.stereotype
		when :entity			
			template = load_template("entity.tpl")
		when :enumeration
			template = load_template("enumeration.tpl")
		else
			return
		end

		@rendered = template.render(@hash)
		path = "#{@project_files}/src/main/java/" + class_builder.package.gsub(".", "/") + "/"	
		file_name = class_builder.name + ".java"
		save(@rendered, path, file_name)		
	end	

	def generate_dao(class_builder)
		if class_builder.stereotype == :entity
			template = load_template("persistence.tpl")
			
			@rendered = template.render(@hash)

			path = "#{@project_files}/src/main/java/" + class_builder.persistence_package.gsub(".", "/") + "/"	
			file_name = class_builder.name + "DAO.java"
			save(@rendered, path, file_name)
		end		
	end

	def generate_bc(class_builder)
		if class_builder.stereotype == :entity
			
			@hash['class'] = class_builder

			template = load_template("businnes.tpl")
			@rendered = template.render(@hash)

			path = "#{@project_files}/src/main/java/" + class_builder.business_package.gsub(".", "/") + "/"	
			file_name = class_builder.name + "BC.java"
			save(@rendered, path, file_name)
		end
	end

=begin
	def generate_view
		template = load_template("view_mb_list.tpl")
		@rendered = template.render(@hash)

		path = "#{@project_files}/src/main/java/" + clazz.view_package.gsub(".", "/") + "/"
		file_name = clazz.name + "ListMB.java"
		save(@rendered, path, file_name)

		template = load_template("view_mb_edit.tpl")
		@rendered = template.render(@hash)

		path = "#{@project_files}/src/main/java/" + clazz.view_package.gsub(".", "/") + "/"
		file_name = clazz.name + "EditMB.java"
		save(@rendered, path, file_name)
	end	

	def generate_web
		template = load_template("view_list.tpl")
		@hash["managed_bean"] = clazz.name.lower_camel_case + "ListMB"
		@rendered = template.render(@hash)

		path = "#{@project_files}/src/main/webapp/"
		file_name = clazz.name.underscore + "_list.xhtml"
		save(@rendered, path, file_name)

		template = load_template("view_edit.tpl")
		@rendered = template.render(@hash)

		path = "#{@project_files}/src/main/webapp/"
		file_name = clazz.name.underscore + "_edit.xhtml"
		save(@rendered, path, file_name)
	end	

	def generate_messages(classes)
		template = load_template("messages.tpl")
		@rendered = template.render('classes' => classes)

		path = "#{@project_files}/src/main/resources/"
		file_name = "messages2.properties"
		
		save(@rendered, path, file_name)		
	end
=end

	def save(content, path, file_name)	
		FileUtils.mkdir_p(path) unless File.exists?(path)
		
		file = File.new("#{path}#{file_name}", "w")
		file.write(content)
		file.close

		App.logger.debug "Template saved in #{path}#{file_name}"
	end

	def create_dirs(params)
		path = "#{@output}/#{params[:project_name]}"		
		FileUtils.mkdir_p(path)		
		FileUtils.mkdir_p("#{path}/dataModel")
		FileUtils.mkdir_p("#{path}/templates")
		FileUtils.mkdir_p("#{path}/project")		
	end

	def create_properties_file(params)

		path = "#{@output}/#{params[:project_name]}"

		project_name = params[:project_name]
		project_group = params[:project_group]		

		properties = Hash.new
		params.each do |propertie, value|			
			properties[propertie.to_s.gsub("_", ".")] = value
		end
		properties["project.persistence.package"] = "#{project_group}.#{project_name}.persistence"
		properties["project.business.package"] = "#{project_group}.#{project_name}.business"		
		Properties.create(path, properties)
	end

	def create_maven_project(params)
		project_name = params[:project_name]
		project_group = params[:project_group]
		version = params[:framework_version]
		artifact_id = params[:project_type]

		@project_files = "#{@output}/#{project_name}/project"
		Dir.chdir(@project_files)

		command = "mvn archetype:generate -DgroupId=#{project_group}.#{project_name} -DartifactId=#{project_name}"
		command = "#{command} -DarchetypeGroupId=br.gov.frameworkdemoiselle.archetypes"
		command = "#{command} -DarchetypeArtifactId=#{artifact_id}"
		command = "#{command} -DarchetypeVersion=#{version} -DinteractiveMode=false"
		
		App.logger.info "Criando projeto maven..."
		system command
		if !$?.nil? && $?.exitstatus != 0
			raise "Falha ao criar o projeto com maven.\n#{command}"
		end

		@project_files = @project_files + "/#{project_name}"
	end	

end
