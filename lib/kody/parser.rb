
class Parser

	def initialize(engine)
		@model = engine.model
		@engine = engine
	end

	def generate
		@engine.generate				
	end

end