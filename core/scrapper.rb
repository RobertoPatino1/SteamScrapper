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

#-------------------------------------------------------------

#-------------------------------------------------------------
#Obtener el promedio de las reseñas y los precios por categoría
def prom_resena_precio(codigo)

  url = "https://store.steampowered.com/search/?tags=#{codigo}&ndl=1"
  html = URI.open(url)
  doc = Nokogiri::HTML(html)

  total_juegos = 0
  suma_resenas = 0
  suma_precios = 0
  
  doc.css('.search_result_row').each do |game|
    
    resena_juego = game.css('.search_review_summary').attr('data-tooltip-html')&.value.to_s.split(" ")[4]&.gsub(',', '')
    precio = game.css('.discount_final_price').text.strip.gsub(/\$/, '').to_f

    total_juegos += 1

    suma_resenas += resena_juego.to_i if resena_juego
    suma_precios += precio

  end
  
  if total_juegos == 0
    total_juegos = 50
  end
  # Calcular promedio
  promedio_resenas = suma_resenas / total_juegos
  promedio_precios = (suma_precios / total_juegos).round(2)
  [promedio_resenas, promedio_precios]
end

#-------------------------------------------------------------
#-------------------------------------------------------------
#Obtener el total de juegos entre categoría y plataforma
def total_categoria_plataforma(codigo, plataforma)
  url = "https://store.steampowered.com/search/?tags=#{codigo}&os=#{plataforma}&ndl=1"

  html = URI.open(url).read
  doc = Nokogiri::HTML(html)
  
  result_div = doc.css('#search_results_filtered_warning div')[0]
  
  result_text = result_div.text.split(' ')[0]&.gsub(',', '') if result_div
  
  result_text.to_i if result_div
end

#-------------------------------------------------------------
#-------------------------------------------------------------
#Guardar datos de promedio de las reseñas, precios, total de juegos por categoría

def datos_categoria
  nombre_codigo_hash = {}
  l_categorias_completa = []
  CSV.foreach('codigos_categorias_juegos.csv', headers: true) do |row|
    nombre_codigo_hash[row['Nombre']] = row['Código'].to_i
    l_categorias_completa << row['Nombre']
  end

  l_categorias_muestra = ["singleplayer",
    "3d",
    "action", "adventure", "strategy", "casual", "building", "sports", "2d", "sandbox", "arcade", "fantasy", "horror", "colorful", "simulation", "indie", "racing", "puzzle", "card game", "vr"]
  
  
  CSV.open("datos_categoria.csv", 'w') do |csv|
    #Linea de cabecera
    csv << ['Nombre', 'Promedio de Resenas', 'Promedio de Precios', 'windows', 'mac', 'linux']
    
    #Para probar se puede usar la lista de muestra
    #Verificar que esté en modo "w"
    l_categorias_muestra.each do |categoria|

    #-------------------------------------------------
    #La lista completa demora alrededor de 20 - 35 minutos en extraer todos los datos y es recomendable iterar de 170 en 170
    #Para la primera iteración verificar que esté en modo "w"
    #l_categorias_completa[0..169].each do |categoria|
      
    #Desde la segunda iteracion comentar la linea de cabecera
    #Cambiar el modo de escritura: "a"
    #l_categorias_completa[170..339].each do |categoria|
    #l_categorias_completa[340..-1].each do |categoria|
    #-------------------------------------------------

      
      codigo = nombre_codigo_hash[categoria]
      promedio_resenas, promedio_precios = prom_resena_precio(codigo)
      total_windows = total_categoria_plataforma(codigo, "win")
      total_mac = total_categoria_plataforma(codigo, "mac")
      total_linux = total_categoria_plataforma(codigo, "linux")

      csv << [categoria, promedio_resenas, promedio_precios, total_windows, total_mac, total_linux] if promedio_resenas != 0 && promedio_precios != 0 && total_windows && total_mac && total_linux

    end
  end
end
#-------------------------------------------------------------
#-------------------------------------------------------------

def count_games_by_language_to_csv(languages)
    File_Handler.create_file("games_by_language.csv", ["Idioma", "Total de juegos disponibles"])

    languages.each do |language|
      page_url = "#{@url}?supportedlang=#{language}&ndl=1"
      steam_html = URI.open(page_url)
      data = steam_html.read
      parsed_content = Nokogiri::HTML(data)

      filtered_warning = parsed_content.css('#search_results_filtered_warning div').text.strip

      match = /(\d+,*\d*)\s+results match your search\.(\s*(\d+,*\d*)\s+titles have been excluded based on your preferences(\. However, none of these titles would appear on the first page of results\.)?)?/.match(filtered_warning)

      total_results = match[1].gsub(',', '').to_i if match && match[1]

      puts "Writing data for language #{language}..."
      File_Handler.write_to_file('games_by_language.csv', [language, total_results])
    end
  end
  
def count_vr_games_to_csv
  total_vr_games = 0
  exclusive_vr_games = 0

  [401, 402].each do |vr_type|
    page_url = "#{@url}&vrsupport=#{vr_type}"
    steam_html = URI.open(page_url)
    data = steam_html.read
    parsed_content = Nokogiri::HTML(data)

    filtered_warning = parsed_content.css('#search_results_filtered_warning div').text.strip

    match = /(\d+,*\d*)\s+results match your search\. (\d+,*\d*) titles have been excluded based on your preferences(\. However, none of these titles would appear on the first page of results\.)?/.match(filtered_warning)

    total_results = match[1].gsub(',', '').to_i
    excluded_titles = match[2].gsub(',', '').to_i

    total_vr_games += total_results
    exclusive_vr_games += excluded_titles
  end

  write_vr_info_to_csv(total_vr_games, exclusive_vr_games)
end

def write_vr_info_to_csv(total_vr_games, exclusive_vr_games)
  File_Handler.create_file("vr_games_info.csv", ["Total de juegos con soporte VR", "Total de juegos exclusivos para VR"])
  File_Handler.write_to_file('vr_games_info.csv', [total_vr_games, exclusive_vr_games])
end

  def extract_game_prices
    File_Handler.create_file('game_both_price.csv', ['Titulo', 'Precio Original', 'Precio Final con Descuento'])

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
        original_price = game.css('.discount_original_price').text.strip
        final_price = game.css('.discount_final_price').text.strip

        puts "Writing data from the game: #{title}..."
        File_Handler.write_to_file('game_both_price.csv', [title, original_price, final_price])

        remaining_lines -= 1
        break if remaining_lines <= 0
      end

      break if remaining_lines <= 0

      current_page += 1
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

