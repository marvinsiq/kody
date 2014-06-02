class ProjectBuilder

	def initialize(group, name)
		@name = name
		@group = group
	end

	def to_liquid
	  {
	  	'group' => @group,
	  	'name'=> @name
	  }
	end

end