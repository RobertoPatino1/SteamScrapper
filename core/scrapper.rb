require 'open-uri'
require 'nokogiri'
require 'csv'
require './core/file_handler'
class Scrapper

    attr_accessor :url

    def initialize(url)
        @url = url
    end

    def extract_games
        File_Handler.create_file("games.csv",["Titulo","Fecha de lanzamiento","Precio", "Plataformas"])
        steam_html = URI.open(@url)
        data = steam_html.read
        parsed_content = Nokogiri::HTML(data)

        parsed_content.css('#search_resultsRows a.search_result_row').each do |game|
        title = game.css('.search_name .title').text.strip
        release_date = game.css('.search_released').text.strip
        price = game.css('.search_price_discount_combined .discount_final_price').text.strip

        platform_info = extract_platform_info(game)

        puts "#{title} - #{release_date} - #{price} - Plataformas: #{platform_info}"
        end
    end

    def extract_platform_info(game)
        platform_span = game.css('.search_name .platform_img')
        
        platform_info = platform_span.map do |span|
        span['class'].split.last 
        end.join('-')

        platform_info.empty? ? 'No disponible' : platform_info
    end


end
