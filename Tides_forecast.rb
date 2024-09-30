#!/usr/bin/env ruby

# https://github.com/zach-capalbo/flammarion
# https://www.tide-forecast.com/

require 'flammarion'
require 'colorized'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'

db = SQLite3::Database.open 'data_countries_ports.db'

db.execute <<~SQL
  CREATE TABLE IF NOT EXISTS data(
    id INTEGER NOT NULL PRIMARY KEY,
    Countries TEXT,
    Ports TEXT
  )
SQL

def write(db, v, x)
  v.each_with_index{ |n, o| db.execute "INSERT INTO data (Countries, Ports) VALUES (?, ?)", [n, x[o]] }
end

def clear_all(db)
  db.execute "DELETE FROM data"
  db.execute "VACUUM"
end

def read_all(db)
  cnty_lit = []
  ports_lit = []
  db.execute("SELECT * FROM data") do |row|
    cnty_lit << row[1]
    ports_lit << row[2]
  end
  return cnty_lit, ports_lit
end

tempo_path_link = []
total_port = [] 
total_port_str = []

f = Flammarion::Engraving.new
f.title("Tides forecast")
f.puts "************************************ Choose what you want to do ************************************".colorize(:cyan)
f.puts "Note : scraping (https://www.tide-forecast.com/) entirely for creating new database takes between 5-10 minutes, so be patient".colorize(:coral)
use_bdd = f.checkbox "Use datas stored in the database                    ".colorize(:green)
new_bdd = f.checkbox "Create a new database (countries and ports list)    ".colorize(:green)
f.button("I made my choice".light_red){
  if(use_bdd.checked?)
    tempo_path_link, total_port_str = read_all(db)
    f.table(
      [%w[----Countries---- -----------------------------------------------------------------------------------Ports-----------------------------------------------------------------------------------].map{|h| h.light_magenta}] +
      tempo_path_link.count.times.collect{|x| [tempo_path_link[x], total_port_str[x]]})

  elsif(new_bdd.checked?)
    clear_all(db)
    county_index = Nokogiri::HTML(URI.open('https://www.tide-forecast.com/countries'))
    pre_search = county_index.search('a')

    cp = 7
    begin
      tmp = pre_search[cp].to_s.gsub('<a class="has-icons-left has-text-secondary countries-li" href="/countries/', '').gsub('">', '')
      tempo_path_link << tmp[0..tmp.index("\n")].chomp
      cp += 1
    end while(cp <= pre_search.length()-11)

    for ii in tempo_path_link
      port_country = []
      if(ii.include?("/regions"))
        ii = ii.gsub("/regions", "?top100=yes")
      end
      url_with_cnty = 'https://www.tide-forecast.com/countries/' + ii
      begin
      county_index = Nokogiri::HTML(URI.open(url_with_cnty))
      rescue OpenURI::HTTPError
        nil
      end

      sea = county_index.search('a.has-addon-right')
      coo = 0
      begin
        tmp = sea[coo].to_s.gsub('<a class="has-addon-right" href="/locations/', '').gsub('/tides/latest">', '')
        tmp_port = tmp[0..tmp.index("\n")].chomp
        port_country << tmp_port
        coo += 1
      end while(coo <= sea.length())
      port_country.pop
      total_port << port_country
    end

    for ell in total_port
      tem = ""
      tem << ell.join(',')
      total_port_str << tem
    end

    write(db, tempo_path_link, total_port_str)
    sleep 1
    tempo_path_link, total_port_str = read_all(db)

    f.table(
      [%w[----Countries---- -----------------------------------------------------------------------------------Ports-----------------------------------------------------------------------------------].map{|h| h.light_magenta}] +
      tempo_path_link.count.times.collect{|x| [tempo_path_link[x], total_port_str[x]]})
  end
}

f.puts "Write the place name (see the world places names list just under) you want the tides : ".light_blue
port = f.input(">")

f.button("Get your tides now !!!".light_red) {
  f.puts ""
  f.puts "--------------------------------------------------------------------------------".colorize(:yellow)
  f.puts "Location where you want the tides :  #{port.to_s}".colorize(:yellow)
  f.puts "--------------------------------------------------------------------------------".colorize(:yellow)

  url_port = "https://www.tide-forecast.com/locations/" + "#{port.to_s}" + "/tides/latest"
  begin
    doc = Nokogiri::HTML(URI.open(url_port))
    rescue OpenURI::HTTPError
      nil
  end

  valone = doc.search('b')
  ttime = []
  valtwo = doc.search('b.js-two-units-length-value__primary')
  hheight = []
  valthree = doc.search('span.tide-day-tides__secondary')
  ddate = []

  l = 0
  n = 0
  m = 0
  begin
    if(l == 8)
      l = 20
    end
    ttime << valone[l].to_s.gsub("<b>", "").gsub("</b>", "").gsub(" ", "")
    hheight << valtwo[m].to_s.gsub('<b class="js-two-units-length-value__primary">', "").gsub("</b>", "")
    ddate << valthree[n].to_s.gsub('<span class="tide-day-tides__secondary">(', "").gsub(")</span>", "")
    l += 2
    m += 1
    n += 2
  end while(n <= valone.length()-14)

  f.table(
    [%w[----------Day---------- ---Hours--- --Height--].map{|h| h.light_magenta}] +
    ddate.count.times.collect{|x| [ddate[x], ttime[x], hheight[x]]})
}
f.wait_until_closed
