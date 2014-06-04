require File.join(File.dirname(__FILE__), 'kody/app.rb')
require File.join(File.dirname(__FILE__), 'kody/model.rb')
require File.join(File.dirname(__FILE__), 'kody/parser.rb')
require File.join(File.dirname(__FILE__), 'kody/util.rb')
require File.join(File.dirname(__FILE__), 'kody/engine/demoiselle/demoiselle.rb')

class Kody

	def initialize
		@inicio = Time.now
		App.logger.info "#{App.specification.summary} version #{App.specification.version}"
	end

	def from_xmi_file(file)
		init_properties
		@model = Model.new file
	end

	def engine(type, version)

		case type 
		when "demoiselle-minimal"
		when "demoiselle-jsf-jpa"
			@engine = Demoiselle.new(@model, @properties)
			@engine.output = Dir.pwd		
		else
			raise "Engine '#{type}' not supported."
		end
		App.logger.info "Using the engine '#{@engine.name}' version #{version}."
	end

	def generate
		
		init_properties
		engine(@properties["project.type"], @properties["framework.version"])
		raise "You need define a engine." if @engine.nil?
		
		parser = Parser.new(@engine)
		parser.generate

		App.logger.info "Done: #{Util.diff_time(@inicio)}"

	end

	def create_project(params)

		engine(params[:project_type], params[:framework_version])
		@engine.create_project(params)

		App.logger.info "#{Util.diff_time(@inicio)}"
	end	

	private

	def init_properties		
		@properties = Properties.load(Dir.pwd) if @properties.nil?
	end

end