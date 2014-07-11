
class Parser

	def initialize(engine)
		@model = engine.model
		@engine = engine
	end

	def generate
		@engine.generate				
	end

	def generate_template(template_path, output)
		@engine.generate_template(template_path, output)			
	end	

end