require 'open-uri'
require 'nokogiri'
require 'csv'

class Scrapper

    attr_accessor :url

    def initialize(url)
        @url = url
    end


    def extractGames
        steam_html = URI.open(@url)
        data = steam_html.read
        parsed_content = Nokogiri::HTML(data)

        parsed_content.css('#search_resultsRows a.search_result_row').each do |game|
            title = game.css('.search_name .title').text.strip
            release_date = game.css('.search_released').text.strip
            price = game.css('.search_price_discount_combined .discount_final_price').text.strip

            puts "#{title} - #{release_date} - #{price}"
        end
    end

    def writeToFile(filename)

    end


end
