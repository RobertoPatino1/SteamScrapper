require 'open-uri'
require 'nokogiri'
require './core/file_handler'

class Scrapper
    attr_accessor :url

    def initialize(url)
        @url = url
    end

    def extract_games
        File_Handler.create_file("games.csv", ["Titulo", "Fecha de lanzamiento", "Precio", "Plataformas", "Total de Reviews"])
        page = 1
        total_lines = 100

        loop do
            page_url = "#{@url}?page=#{page}"
            steam_html = URI.open(page_url)
            data = steam_html.read
            parsed_content = Nokogiri::HTML(data)

            games = parsed_content.css('#search_resultsRows a.search_result_row')

            break if games.empty?

            games.each do |game|
                title = game.css('.search_name .title').text.strip
                release_date = game.css('.search_released').text.strip
                price = game.css('.search_price_discount_combined .discount_final_price').text.strip

                platform_info = extract_platform_info(game)
                reviews = extract_reviews(game)

                puts "Writing data from the game: #{title}..."
                File_Handler.write_to_file('games.csv', [title, release_date, price, platform_info, reviews])

                total_lines -= 1
                break if total_lines <= 0
            end

            break if total_lines <= 0
            page += 1
        end
    end

    def extract_platform_info(game)
        platform_span = game.css('.search_name .platform_img')

        platform_info = platform_span.map do |span|
            span['class'].split.last
        end.join('-')
        platform_info.empty? ? 'No disponible' : platform_info
    end



    def extract_reviews(game)
        review_summary = game.css('.search_review_summary')
        reviews_html = review_summary.first['data-tooltip-html'] if review_summary.first
        match = /(\d+,*\d*)\s+user reviews/.match(reviews_html)
        reviews_number = match ? match[1].gsub(',', '') : 'N/A'
        reviews_number
    end



end

