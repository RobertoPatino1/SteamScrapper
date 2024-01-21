# Agregando librerias requeridas


# Agregando clases creadas
require './core/scrapper'


MAIN_URL = 'https://store.steampowered.com/search/'
#Creando el objeto de tipo scrapper
scrapper = Scrapper.new(MAIN_URL)
scrapper.extract_games()

scrapper.extraer_codigos_categorias()          

categoria = 'atmospheric'

scrapper.extraer_titulos_categoria(categoria)

