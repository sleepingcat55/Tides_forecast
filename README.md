# Tides_forecast

This small software scrapes data from https://www.tide-forecast.com/ to get countries/ports names and then
ask you the tides forecast you want for. Then, it scrape again the website to get the datas
Scraping all the website for countries/ports names takes 5-10 minutes, so I add a database to don't
forget these data and make the software faster

![Tides forecast 1](https://github.com/user-attachments/assets/cb71caba-b2a6-4b56-a471-8e5cca6aa6b6)

![Tides forecast 2](https://github.com/user-attachments/assets/9b6dc49f-86ac-48ce-82c4-1219556af174)

# How to use

- Be sure the next gems are installed or install them : open-uri, nokogiri, flammarion, colorized, sqlite3
- write in a Terminal : sudo chmod 755 Tides_forecast.rb
- launch the software with the Terminal : ./Tides_forecast.rb

# Credits

I used :
- Flammarion GUI Toolkit : https://github.com/zach-capalbo/flammarion
- for the data : https://www.tide-forecast.com/
- Gems :
-  open-uri and nokogiri for the scraping
-  flammarion and colorized for the GUI
-  sqlite3 for the database
