# encoding: utf-8

class Properties

	def self.load(properties_path)
		raise "Arquivo de propriedades não existe (#{properties_path})." unless File.exists? properties_path
	    properties = {}
	    linha_em_branco = 1
	    File.open(properties_path, 'r') do |properties_file|
	      properties_file.read.each_line do |line|
	        line.strip!
	        if (line[0] != ?# and line[0] != ?=)
	          i = line.index('=')
	          if (i)
	            properties[line[0..i - 1].strip] = line[i + 1..-1].strip
	          else
	            properties["#" + linha_em_branco.to_s] = ''
	            linha_em_branco = linha_em_branco + 1
	          end
	        end
	      end
	    end
	    properties
	end

	def self.save(properties, properties_path)
		File.open(properties_path, 'w') do |f|
			properties.each do |key, value|
				if value.empty? && key[0] == "#"
					f.puts "\n"
				else
					f.puts "#{key}=#{value}\n"
				end
			end
		end
		App.logger.info "Arquivo de propriedades salvo em #{properties_path}"
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