# Agregando librerias requeridas


# Agregando clases creadas
require './core/scrapper'


MAIN_URL = 'https://store.steampowered.com/search/'
#Creando el objeto de tipo scrapper
scrapper = Scrapper.new(MAIN_URL)
scrapper.extract_games()

scrapper.extraer_codigos_categorias()

scrapper.count_vr_games_to_csv

languages = ['english', 'simplifiedchinese', 'traditionalchinese', 'japanese', 'korean', 'thai', 'bulgarian', 'czech', 'danish', 'german', 'spanish', 'spanishlatinamerica', 'greek', 'french', 'italian', 'indonesian']

scrapper.count_games_by_language_to_csv(languages)

categoria = 'atmospheric'

scrapper.extraer_titulos_categoria(categoria)

scrapper2 = Scrapper.new("https://store.steampowered.com/search/?specials=1&ndl=1")

scrapper2.extract_game_prices
