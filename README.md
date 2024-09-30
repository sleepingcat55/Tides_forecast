# Tides_forecast

This small software scrapes data from https://www.tide-forecast.com/ to get countries/ports names and then
ask you the tides forecast you want for. Then, it scrape again the website to get the datas
Scraping all the website for countries/ports names takes 5-10 minutes, so I add a database to don't
forget these data and make the software faster

# Credits

I used :
- Flammarion GUI Toolkit : https://github.com/zach-capalbo/flammarion
- for the data : https://www.tide-forecast.com/
- Gems :
-  open-uri and nokogiri for the scraping
-  flammarion and colorized for the GUI
-  sqlite3 for the database
