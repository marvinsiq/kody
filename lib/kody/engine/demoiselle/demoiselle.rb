# encoding: utf-8

require 'fileutils'
require 'liquid'
require 'kody/modules'
require 'kody/string'
require 'kody/properties'
require 'kody/builder/class_builder'
require 'kody/builder/project_builder'
require 'kody/engine/engine'
require 'kody/engine/demoiselle/datatype'

class Demoiselle < Engine

	attr_accessor :output
	attr_accessor :models

	def initialize(models=nil)
		super()
		@output = Dir.pwd
		@hash = Hash.new	

		@models = models
		if !models.nil?

			properties_filename = "#{App.specification.name}.properties"
			properties_path = "#{@output}/#{properties_filename}"
			App.logger.info "Loading project property file #{properties_filename}..."

			self.properties = Properties.load(properties_path)
			App.logger.info "Initializing builders..."
			models.each {|model| initialize_builders(model) }	
		end
		@project_files = @output + "/" + @properties["module"]
	end

	def initialize(models, _properties)
		super()
		@output = Dir.pwd
		@hash = Hash.new	
		self.properties = _properties
		@models = models
		if !models.nil?
			App.logger.info "Initializing builders..."
			models.each {|model| initialize_builders(model) }
		end
		@project_files = @output + "/" + _properties["module"]	
	end

	def properties=(properties)
		@properties = properties
		unless(@properties.nil?)

			@properties.each do |key, value|
				# Mapeando as propriedades do arquivo kody.properties nos templates.
				# Substitui os pontos por "_".
				# Exemplo de mapeamento:
				# => project.name = project_name
				@hash[key.gsub(".", "_")] = value
			end			
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
		create_maven_project(params, @output + "/" + params[:project_name])
		create_properties_file(params)		

		App.logger.info "Project #{params[:project_name]} created."		
	end

	# Cria um novo módulo para o projeto
	def add_module(params)

		create_maven_project(params, @output)

		App.logger.info "Project #{params[:project_name]} created."		
	end	

	def generate(templates)

		if templates.include?("domain")
			App.logger.info "Generating template \"domain\"."
			generate_domain
		end
		
		if templates.include?("enum")
			App.logger.info "Generating template \"enum\"."
			generate_enumerations
		end
		
		if templates.include?("business")
			App.logger.info "Generating template \"business\"."
			generate_business
		end
		
		if templates.include?("persistence")
			App.logger.info "Generating template \"persistence\"."
			generate_persistence
			generate_persistence_xml
		end
		
		if templates.include?("crud-jsf2")
			App.logger.info "Generating template \"crud-jsf2\"."
			generate_managed_bean
			generate_xhtml
			generate_messages_properties
		end

		if templates.include?("use-case")
			App.logger.info "Generating template \"use-case\"."
			generate_use_case
		end		

	end

	def convert_type(type)
		Datatype.java_type(type)
	end	

	private

	##
	# Gera os Beans
	#
	def generate_domain
		@entities.each do |clazz|
			@hash['class'] = clazz

			if clazz.stereotype == :entity
				template = load_template("entity.tpl")
				@rendered = template.render(@hash)
				path = "#{@project_files}/src/main/java/" + clazz.package.gsub(".", "/")
				file_name = clazz.name + ".java"
				save(@rendered, path, file_name)
			end
		end
	end

	##
	# Gera as enumerações
	#
	def generate_enumerations
		@enumerations.each do |clazz|
			@hash['class'] = clazz

			if clazz.stereotype == :enumeration
				template = load_template("enumeration.tpl")
				@rendered = template.render(@hash)
				path = "#{@project_files}/src/main/java/" + clazz.package.gsub(".", "/")
				file_name = clazz.name + ".java"
				save(@rendered, path, file_name)
			end				
		end	
	end	

	##
	# Gera as classes da camada de negócio baseada nas entidades
	#
	def generate_business
		@entities.each do |clazz|

			if clazz.stereotype == :entity
				
				@hash['class'] = clazz

				template = load_template("business.tpl")
				@rendered = template.render(@hash)

				business_package = @properties["project.business.package"]
				path = "#{@project_files}/src/main/java/" + business_package.gsub(".", "/")	
				file_name = clazz.name + "BC.java"

				save(@rendered, path, file_name, false)
			end			
		end		
	end

	## 
	# Gera as classes da camada de persistencia baseada nas entidades
	#
	def generate_persistence
		@entities.each do |clazz|
			@hash['class'] = clazz
			if clazz.stereotype == :entity
				template = load_template("persistence.tpl")
				
				@rendered = template.render(@hash)

				persistence_package = @properties["project.persistence.package"];
				path = "#{@project_files}/src/main/java/" + persistence_package.gsub(".", "/")	
				file_name = clazz.name + "DAO.java"
				save(@rendered, path, file_name, false)
			end		
		end
	end
	
	# Gera o arquivo de configuração do JPA
	def generate_persistence_xml

		path = "#{@project_files}/src/main/resources/META-INF/"
		file_name = "persistence.xml"

		full_file_name = "#{path}#{file_name}"
		process_template("persistence.xml.tpl", "persistence.xml.partial.tpl", full_file_name)

		path = "#{@project_files}/src/test/resources/META-INF/"
		
		full_file_name = "#{path}#{file_name}"
		process_template("persistence_test.xml.tpl","persistence.xml.partial.tpl", full_file_name)		
	end	

	def load_template(template_name)
		full_template_name = File.expand_path File.dirname(__FILE__) + "/templates/" + template_name
		load_template_path(full_template_name)
	end

	def process_template(template, partial_template, file_name)
		
		# Verifica se arquivo existe		
		if File.exist?(file_name)
				
			file_content = File.read(file_name)
			search = "<!-- <PartialkodyGen> -->"
			search2 = "<!-- </PartialkodyGen> -->"
			index = file_content.index(search)

			template = load_template(partial_template)
			rendered = template.render('classes' => @entities)

			if index.nil?
				App.logger.debug "File '#{file_name}' exists."
				App.logger.debug "Insert tag <!-- <PartialkodyGen> --><!-- </PartialkodyGen> --> to generate parts."
				return
			else

				index2 = file_content.index(search2)				 
				if index2.nil?
					index2 = index
					search2 = search
				else
					index2 = index2 - search2.size
				end

				rendered = file_content[0, index + search.size] + 
				"\n\n#{rendered}" + file_content[index2 + search2.size, file_content.size]
			end			
		else
			template = load_template(template)
			rendered = template.render('classes' => @entities)
		end
		save(rendered, file_name)		
	end	

	def generate_managed_bean

		@entities.each do |clazz|
			if clazz.stereotype == :entity

				@hash['class'] = clazz

				template = load_template("view_mb_list.tpl")
				@rendered = template.render(@hash)

				view_package = @properties["project.view.package"]

				path = "#{@project_files}/src/main/java/" + view_package.gsub(".", "/") + "/"
				file_name = clazz.name + "ListMB.java"
				save(@rendered, path, file_name)

				template = load_template("view_mb_edit.tpl")
				@rendered = template.render(@hash)

				path = "#{@project_files}/src/main/java/" + view_package.gsub(".", "/") + "/"
				file_name = clazz.name + "EditMB.java"
				save(@rendered, path, file_name)
			end
		end
	end	

	def generate_xhtml

		@entities.each do |clazz|
			if clazz.stereotype == :entity

				@hash['class'] = clazz	

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
		end		
	end	

	def generate_messages_properties

		template = load_template("messages.tpl")
		@rendered = template.render('classes' => @entities)

		path = "#{@project_files}/src/main/resources/"
		file_name = "messages2.properties"
		
		save(@rendered, path, file_name)
	end

	def generate_use_case
		@use_cases.each do |use_case|

			App.logger.info "Use Case: " + use_case.name

			messages_properties_file_name = "#{@project_files}/src/main/resources/messages.properties"
			messages_properties = Properties.load(messages_properties_file_name)

			use_case.pages.each do |page|
				App.logger.info "Page: " + page.name

				@hash['page'] = page
				template = load_template("page.tpl")
				@rendered = template.render(@hash)

				path = "#{@project_files}/src/main/webapp"
				file_name = page.name.hyphenate + ".xhtml"
				save(@rendered, path, file_name)

				messages_properties[page.property_key] = page.property_value
				page.fields.each do |field|
					messages_properties[field.property_key] = field.property_value
					field.columns.each do |column|
						messages_properties[column.property_key] = column.property_value
					end
					field.actions.each do |action|
						messages_properties["#{field.property_key}.#{action.property_key}"] = action.property_value
					end
				end
				page.actions.each do |action|
					messages_properties["#{page.property_key}.#{action.property_key}"] = action.property_value
				end				
			end
			Properties.save(messages_properties, messages_properties_file_name)

			use_case.controllers.each do |controller|
				App.logger.info "Managed Bean:" + controller.name

				controller.package = @properties["project.view.package"]
				if controller.package.nil? or controller.package.empty?
					controller.package = properties["project.group"] + ".view" 
				end

				@hash['controller'] = controller
				template = load_template("controller.tpl")
				@rendered = template.render(@hash)

				path = "#{@project_files}/src/main/java/" + controller.package.gsub(".", "/")
				file_name = controller.name + ".java"
				save(@rendered, path, file_name)				
			end
		end
	end

	def create_dirs(params)
		path = "#{@output}/#{params[:project_name]}"		
		FileUtils.mkdir_p(path)		
		FileUtils.mkdir_p("#{path}/dataModel")
		FileUtils.mkdir_p("#{path}/templates")
		#FileUtils.mkdir_p("#{path}/project")		
	end

	##
	# Cria o arquivo de propriedades do projeto
	#
	def create_properties_file(params)

		path = "#{@output}/#{params[:project_name]}"

		project_name = params[:project_name]
		project_group = params[:project_group]		

		properties = Hash.new
		params.each do |propertie, value|			
			properties[propertie.to_s.gsub("_", ".")] = value
		end
		properties["project.persistence.package"] = "#{project_group}.persistence"
		properties["project.business.package"] = "#{project_group}.business"
		properties["project.view.package"] = "#{project_group}.view"
		Properties.create(path, properties)
	end

	##
	# Cria o projeto demoiselle utilizando o arquétipo do maven
	#
	def create_maven_project(params, path)
		project_name = params[:project_name]
		project_group = params[:project_group]
		artifact_id = params[:artifact_id]
		version = params[:framework_version]
		archetype_artifact_id = params[:project_type]		

		@project_files = path
		#@project_files = @output
		Dir.chdir(@project_files)

		command = "mvn archetype:generate -DgroupId=#{project_group} -DartifactId=#{artifact_id}"
		command = "#{command} -DarchetypeGroupId=br.gov.frameworkdemoiselle.archetypes"
		command = "#{command} -DarchetypeArtifactId=#{archetype_artifact_id}"
		command = "#{command} -DarchetypeVersion=#{version} -DinteractiveMode=false"
		
		App.logger.info "Criando projeto maven..."
		system command
		if !$?.nil? && $?.exitstatus != 0
			raise "Falha ao criar o projeto com maven.\n#{command}"
		end

		@project_files = @project_files + "/#{project_name}"
	end	

end
