require 'logger'
require 'rake'

class App

	@@log = nil
	@@spec = nil
	@@abbreviations = nil

	def self.logger
		
		return @@log unless @@log.nil?

		@@log = Logger.new($stdout)
		@@log.level = Logger::DEBUG
		@@log.formatter = proc do |severity, datetime, progname, msg|
		  "[#{severity}] - #{msg}\n"
		end
		@@log
	end

	def self.specification

		return @@spec unless @@spec.nil?

		@@spec = Gem::Specification.new do |s|
		  s.name        = 'kody'
		  s.version     = '0.0.2'
		  s.licenses    = ['LGPL']
		  s.add_runtime_dependency "thor", '~> 0.18', '>= 0.18.1'
		  s.add_runtime_dependency "rake", '~> 0.9', '>= 0.9.2'
		  s.add_runtime_dependency "nokogiri", '~> 1.6', '>= 1.6.0'
		  s.add_runtime_dependency "liquid", '~> 2.5', '>= 2.5.0'
		  s.add_runtime_dependency "xmimodel", '~> 0.2', '>= 0.2.0'
		  s.date        = '2014-06-02'
		  s.summary     = "Kody"
		  s.description = "A quick code generator."
		  s.authors     = ["Marcus Siqueira"]
		  s.email       = 'marvinsiq@gmail.com'
		  s.files       = FileList['lib/*.rb', 'lib/**/*.rb', 'lib/**/*'].to_a
		  s.homepage    = 'https://github.com/marvinsiq/kody'
		  s.executables << 'kody'
		end
	end

	def self.abbreviations
		return @@abbreviations unless @@abbreviations.nil?

		properties_filename = "abbreviations.properties"

		return Array.new unless File.exists? properties_filename

		App.logger.info "Loading property file #{properties_filename}..."

	    @@abbreviations = {}
	    File.open(properties_filename, 'r') do |properties_file|
	      properties_file.read.each_line do |line|
	        line.strip!.downcase!
	        if (line[0] != ?# and line[0] != ?=)
	          i = line.index('=')
	          if (i)
	            @@abbreviations[line[0..i - 1].strip.downcase] = line[i + 1..-1].strip.downcase
	          else
	            @@abbreviations[line] = ''
	          end
	        end
	      end
	    end

		@@abbreviations		
	end

end