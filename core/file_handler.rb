require 'csv'

class File_Handler
    
    def self.create_file(filename,header)
        CSV.open(filename,'w') do |csv|
            csv<<header
        end
    end

    def self.write_to_file(filename,line)
        CSV.open(filename,'a') do |csv|
            csv<<line
        end
    end
end