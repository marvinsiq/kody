require File.join(File.dirname(__FILE__), 'kody/app.rb')
require File.join(File.dirname(__FILE__), 'kody/model.rb')
require File.join(File.dirname(__FILE__), 'kody/parser.rb')
require File.join(File.dirname(__FILE__), 'kody/util.rb')
require File.join(File.dirname(__FILE__), 'kody/engine/demoiselle/demoiselle.rb')
require File.join(File.dirname(__FILE__), 'kody/engine/generic/generic_engine.rb')

class Kody

	def initialize(options=nil)
		@inicio = Time.now
		App.logger.info "#{App.specification.summary} version #{App.specification.version}"

		@options = options
	end

	def from_xmi_file(files)
		@models = Array.new
		init_properties
		files.each do |file|
			@models << Model.new(file)
		end		
	end

	def engine(type, version)

		case type 
		when "demoiselle-minimal", "demoiselle-jsf-jpa"
			@engine = Demoiselle.new(@models, @properties)
			@engine.output = Dir.pwd		
		else
			raise "Engine '#{type}' not supported."
		end 
		App.logger.info "Using '#{@engine.name}' engine, version #{version}."
	end

	def generate
		
		init_properties
		@properties["module"] = @options[:module]

		engine(@properties["project.type"], @properties["framework.version"])
		raise "You need define a engine." if @engine.nil?
		
		templates = @options[:templates].split

		parser = Parser.new(@engine)
		parser.generate(templates)

		App.logger.info "Done: #{Util.diff_time(@inicio)}"

	end

	def create_project(params)

		engine(params[:project_type], params[:framework_version])
		@engine.create_project(params)

		App.logger.info "#{Util.diff_time(@inicio)}"
	end

	def add_module(params)
		
		init_properties

		@properties["module"] = params[:artifact_id]

		engine(params[:project_type], params[:framework_version])
		raise "You need define a engine." if @engine.nil?

		@engine.add_module(params)

		App.logger.info "#{Util.diff_time(@inicio)}"		
	end

	def generate2(model_file, template, classes, output)
		
		@model = [Model.new(model_file)]

		@engine = GenericEngine.new(@models, @properties)
		@engine.output = Dir.pwd
		App.logger.info "Using '#{@engine.name}' engine, version #{@engine.version}."
		
		parser = Parser.new(@engine)
		parser.generate_template(template, output)

		App.logger.info "Done: #{Util.diff_time(@inicio)}"

	end	

	private

	def init_properties

		properties_filename = "#{App.specification.name}.properties"
		properties_path = "#{Dir.pwd}/#{properties_filename}"
		App.logger.info "Loading project property file #{properties_filename}..."

		@properties = Properties.load(properties_path) if @properties.nil?
	end

end