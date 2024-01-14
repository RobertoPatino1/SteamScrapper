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
        games = parsedContent.css('#search_resultsRows .title').inner_text
        parsedContent.css('#search_resultsRows .title').each do |game|
            #Nombre del juego
            puts game.inner_text
        end
        # puts games
    end

    def writeToFile(filename)

    end


end
