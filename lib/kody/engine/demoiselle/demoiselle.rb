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
		return "Demoiselle"
	end

	def version
		return "2.3.2"
	end

	# Cria um novo projeto
	def create_project(params)

		create_dirs(params)
		create_properties_file(params)
		create_maven_project(params)
		#generate_pom_xml(params)

		App.logger.info "Project #{params[:project_name]} created."		
	end

	def generate
		generate_domain
		generate_enumerations
		generate_businnes
		generate_persistence_xml
	end

	# Cria o arquivo de configuração do maven
	def generate_pom_xml params
		template = load_template("pom.xml.tpl")
		path = output + "/" + params[:project_name] + "/" + params[:project_type] + "/"
		file_name = "pom.xml"

		rendered = template.render(
			'project' => ProjectBuilder.new(params[:project_group], params[:project_name]))
		save(rendered, path, file_name)		
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
		path = output + "/src/main/resources/META-INF/"
		file_name = "persistence.xml"
		rendered = template.render('classes' => @entities)
		save(rendered, path, file_name)
		path = output + "/src/test/resources/META-INF/"
		save(rendered, path, file_name)	
	end	

	public
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
	def generate_dao(clazz)
		if clazz.stereotype == :entity
			template = load_template("persistence.tpl")
			
			@rendered = template.render(@hash)

			path = output + "/src/main/java/" + clazz.persistence_package.gsub(".", "/") + "/"	
			file_name = clazz.name + "DAO.java"
			save(@rendered, path, file_name)
		end		
	end

	def generate_bc(clazz)
		if clazz.stereotype == :entity
			
			@hash['class'] = clazz

			template = load_template("businnes.tpl")
			@rendered = template.render(@hash)

			path = output + "/src/main/java/" + clazz.business_package.gsub(".", "/") + "/"	
			file_name = clazz.name + "BC.java"
			save(@rendered, path, file_name)
		end
	end

	def generate_view
		template = load_template("view_mb_list.tpl")
		@rendered = template.render(@hash)

		path = output + "/src/main/java/" + clazz.view_package.gsub(".", "/") + "/"
		file_name = clazz.name + "ListMB.java"
		save(@rendered, path, file_name)

		template = load_template("view_mb_edit.tpl")
		@rendered = template.render(@hash)

		path = output + "/src/main/java/" + clazz.view_package.gsub(".", "/") + "/"
		file_name = clazz.name + "EditMB.java"
		save(@rendered, path, file_name)
	end	

	def generate_web
		template = load_template("view_list.tpl")
		@hash["managed_bean"] = clazz.name.lower_camel_case + "ListMB"
		@rendered = template.render(@hash)

		path = output + "/src/main/webapp/"
		file_name = clazz.name.underscore + "_list.xhtml"
		save(@rendered, path, file_name)

		template = load_template("view_edit.tpl")
		@rendered = template.render(@hash)

		path = output + "/src/main/webapp/"
		file_name = clazz.name.underscore + "_edit.xhtml"
		save(@rendered, path, file_name)
	end	

	def generate_messages(classes)
		template = load_template("messages.tpl")
		@rendered = template.render('classes' => classes)

		path = output + "/src/main/resources/"
		file_name = "messages2.properties"
		
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

	def create_dirs(params)
		path = "#{@output}/#{params[:project_name]}"		
		FileUtils.mkdir_p(path)		
		FileUtils.mkdir_p("#{path}/mda")
		FileUtils.mkdir_p("#{path}/templates")
		FileUtils.mkdir_p("#{path}/project")		
	end

	def create_properties_file(params)

		path = "#{@output}/#{params[:project_name]}"

		project_name = params[:project_name]
		project_group = params[:project_group]		

		properties = Hash.new
		params.each do |propertie, value|			
			properties[propertie.gsub("_", ".")] = value
		end
		properties["project.persistence.package"] = "#{project_group}.#{project_name}.persistence"
		properties["project.business.package"] = "#{project_group}.#{project_name}.business"		
		Properties.create(path, properties)
	end

	def create_maven_project(params)
		project_name = params[:project_name]
		project_group = params[:project_group]
		Dir.chdir("#{@output}/#{project_name}/project")

		command = "mvn archetype:generate -DgroupId=#{project_group} -DartifactId=#{project_name}"
		command = "#{command} -DarchetypeGroupId=br.gov.frameworkdemoiselle.archetypes"
		command = "#{command} -DarchetypeArtifactId=demoiselle-minimal"
		command = "#{command} -DarchetypeVersion=#{version} -DinteractiveMode=false"
		
		App.logger.info "Criando projeto maven..."
		system command
		if !$?.nil? && $?.exitstatus != 0
			raise "Falha ao criar o projeto com maven.\n#{command}"
		end
	end	

end