
class Parser

	def initialize(engine)
		@models = engine.models
		@engine = engine
	end

	def generate(templates)
		@engine.generate(templates)			
	end

	def generate_template(template_path, output)
		@engine.generate_template(template_path, output)			
	end	

end