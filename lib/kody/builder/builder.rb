
class Builder

	def stereotypes(clazz)
		
		stereotypes = Array.new

		clazz.stereotypes.each do |s|
			
			stereotype = nil

			case s.name
			
			when "org.andromda.profile::persistence::Entity", 
				"UML Standard Profile::entity",
				"Entity"
				stereotype = :entity				
			
			when "org.andromda.profile::persistence::WebServiceData"
				stereotype = :web_service_data
			
			when "org.andromda.profile::ApplicationException"
				stereotype = :application_exception
			
			when "org.andromda.profile::Enumeration",
				"UML Standard Profile::UML2.0::enumeration"
				stereotype = :enumeration
			
			when "org.andromda.profile::presentation::FrontEndSessionObject"
				stereotype = :front_end_session_object
			
			when "org.andromda.profile::ValueObject"
				stereotype = :value_object
			
			else
				App.logger.warn "Stereotype desconhecido: '#{s.name}', classe: #{clazz.name}"	
			end

			stereotypes << stereotype unless stereotype.nil?
		end

		if (clazz.class.to_s == "Enumeration") 			
			stereotypes << :enumeration
		end

		return stereotypes
	end

end