require 'xmimodel'
require 'xmimodel/attribute'
require 'xmimodel/clazz'
require 'xmimodel/attribute'

class Model

	attr_reader :doc

	def initialize(model_file_name)
		App.logger.info "Loading model #{model_file_name}..."
		inicio = Time.now
		@model = XmiModel.new model_file_name
		App.logger.info "Model #{model_file_name} loaded (#{Util.diff_time(inicio)})."
	end

	def classes
		@model.classes
	end

end