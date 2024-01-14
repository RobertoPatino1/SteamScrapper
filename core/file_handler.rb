require 'csv'

class File_Handler
    
    def self.create_file(filename,header)
        CSV.open(filename,'w') do |csv|
            csv<<header
        end
    end
end