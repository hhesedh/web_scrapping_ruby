require 'open-uri'
require 'nokogiri'
require 'json'
require 'fileutils'
require 'htmlentities'

# Baixando pagina
def baixar_pagina(url, nome_arq)
  doc = Nokogiri::HTML(Kernel.open(url))
  File.open(nome_arq, 'w') do |line|
    line.puts doc.xpath('//script')
  end
end

# retirando json da pagina
def recupera_json(nome_arq)
  linha = ''
  File.open(nome_arq, 'r').each_line do |line|
    if line.include? 'trackinfo: '
      linha = line
      break
    end
  end
  linha.slice!(-2..-1)
  linha.slice!('    trackinfo: ')
  JSON.parse linha
end

# retirando informações principais da paixna
def hash_de_musicas(informacoes)
  urls = {}

  informacoes.each do |dicionario|
    next if dicionario['file'].nil?

    titulo = dicionario['title'].sub('/', '')
    musica = dicionario['file']['mp3-128']
    urls[titulo] ||= musica
  end
  urls
end

# Retirando nome do album e nomeando pagina
def retirar_nome_album(nome_arq)
  nome_album = ''
  File.open(nome_arq, 'r').each do |line|
    nome_album = line if line.include? 'album_title:'
  end
  nome_album.split('"')[1]
end

# Baixando musica
def baixa_musica(urls, nome_album)
  FileUtils.mkdir_p nome_album
  urls.each do |key, value|
    puts "Baixando musica #{key}..."
    File.open("#{key}.mp3", 'wb') do |file|
      file.print Kernel.open(value).read
    end
    FileUtils.mv "#{key}.mp3", "#{nome_album}/#{key}.mp3"
  end
  puts 'Fim :)'
end

url = ARGV[0]
nome_arq = 'script.txt'

baixar_pagina(url, nome_arq)
informacoes = recupera_json(nome_arq)
lista_musicas = hash_de_musicas(informacoes)
nome_album = retirar_nome_album(nome_arq)
baixa_musica(lista_musicas, nome_album)
File.delete nome_arq
