require 'open-uri'
require 'nokogiri'
require 'csv'

class Scrapper

    attr_accessor :url

    def initialize(url)
        @url = url
    end


    def extractGames()
        steamHTML = URI.open(@url)
        data = steamHTML.read
        parsedContent = Nokogiri::HTML(data)
        # puts parsedContent
        games = parsedContent.css('.responsive_search_name_combined').inner_text
        puts games
    end

    def writeToFile(filename)

    end


end
