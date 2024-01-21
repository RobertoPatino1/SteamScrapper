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

    def extraer_titulos_categoria(categoria)
  nombre_codigo_hash = {}
  CSV.foreach('codigos_categorias_juegos.csv', headers: true) do |row|
    nombre_codigo_hash[row['Nombre']] = row['Código'].to_i
  end

  codigo = nombre_codigo_hash[categoria]

  CSV.open("categoria_#{categoria}.csv", 'a') do |csv|
    csv << ['Nombre']

    url = "https://store.steampowered.com/search/?tags=#{codigo}&ndl=1"
    html = URI.open(url)
    doc = Nokogiri::HTML(html)

    titles = doc.css('span.title')

    titles.each do |title|
      csv << [title.text]
    end
  end
end

def extraer_codigos_categorias
  url = 'https://store.steampowered.com/search/?tags=4182&ndl=1'
  html = URI.open(url)
  doc = Nokogiri::HTML(html)
  filter_rows = doc.css('.tab_filter_control_row')

  data = []
  filter_rows.each do |filter_row|
    loc_value = filter_row['data-loc'].downcase

    value_value = filter_row['data-value']

    data << [loc_value, value_value] if value_value.to_i.to_s == value_value
  end

  CSV.open('codigos_categorias_juegos.csv', 'w') do |csv|
    csv << ["Nombre", "Código"]

    data.each do |row|
      csv << row
    end
  end
end
    
    def extract_game_titles
    File_Handler.create_file("game_titles.csv", ["Titulo"])

    current_page = 1
    remaining_lines = 100

    loop do
        page_url = "#{@url}?page=#{current_page}"
        steam_html = URI.open(page_url)
        data = steam_html.read
        parsed_content = Nokogiri::HTML(data)

        games = parsed_content.css('#search_resultsRows a.search_result_row')

        break if games.empty?
        
        games.each do |game|
            title = game.css('.search_name .title').text.strip

            puts "Writing data from the game: #{title}..."
            File_Handler.write_to_file('game_titles.csv', [title])

            remaining_lines -= 1
            break if remaining_lines <= 0
        end

        break if remaining_lines <= 0
        current_page += 1
    end
end


end

