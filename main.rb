# Agregando librerias requeridas


# Agregando clases creadas
require './core/scrapper'


MAIN_URL = 'https://store.steampowered.com/search/'
#Creando el objeto de tipo scrapper
scrapper = Scrapper.new(MAIN_URL)
scrapper.extract_games()

