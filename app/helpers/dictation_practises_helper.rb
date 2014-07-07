module DictationPractisesHelper
	def get_files_list(path)
		files = []
		puts "#{path}"
		Dir.entries(path).each do |sub|
			if sub != '.' && sub != '..'  
				if File.directory?("#{path}/#{sub}")
					puts "[#{sub}]"  
					#get_file_list("#{path}/#{sub}")  
				else  
					files << sub  
				end  
			end 
		end 
		files 
	end	
end
