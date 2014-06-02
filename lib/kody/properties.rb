# encoding: utf-8

class Properties

	def self.load(project_path)

		properties_filename = "#{App.specification.name}.properties"
		properties_path = "#{project_path}/#{properties_filename}"

		raise "Arquivo de propriedades do projeto não existe (#{properties_filename})." unless File.exists? properties_path

		App.logger.info "Loading property file #{properties_filename}..."

	    properties = {}
	    File.open(properties_path, 'r') do |properties_file|
	      properties_file.read.each_line do |line|
	        line.strip!
	        if (line[0] != ?# and line[0] != ?=)
	          i = line.index('=')
	          if (i)
	            properties[line[0..i - 1].strip] = line[i + 1..-1].strip
	          else
	            properties[line] = ''
	          end
	        end
	      end
	    end
	    properties
	end

	def self.create(project_path, content)
		file_name = "#{project_path}/#{App.specification.name}.properties"

		outFile = File.new(file_name, "w+")
		content.each do |property, value|			
			outFile.puts("#{property.gsub("_", ".")}=#{value}")
		end
		outFile.close		
	end

end