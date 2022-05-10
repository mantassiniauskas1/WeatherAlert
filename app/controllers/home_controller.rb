class HomeController < ApplicationController

require "net/http"
require 'resolv-replace'

  def main

    scheduler = Rufus::Scheduler.new
    scheduler.cron '00 12 * * *' do   # 12:00am utc == Pacific time 05:00am, Mountain time 06:00am, Central time 07:00am, Eastern time 08:00am
      runner HomeController.new.main
    end
 
    for i in 0..((Driver.all).length-1)

      @driver = Driver.all[i]

      results = Geocoder.search([@driver.latitude, @driver.longitude]) #coordinates to location
      @state = results[0].state_code
      state = Madison.get_abbrev (results[0].state_code) #state name to abbreviation 

      url = "https://api.weather.gov/alerts/active?area=" + state;
      response = Net::HTTP.get_response(URI.parse(url))
      data = JSON.parse(response.body)
      featuresLength = data["features"].length() - 1

      @output = ""
      arr = []
      arrN = []
      arrWMO = []
      unique = 1

      for i in 0..featuresLength
        par = data["features"][i]["properties"]
        if ["Severe", "Critical"].include? par["severity"]
            if arrWMO.include? par["parameters"]["WMOidentifier"][0].split.first
              unique = 0
            end

            if unique == 1
              arrWMO.push par["parameters"]["WMOidentifier"][0].split.first
              arr.push par["areaDesc"]
              arr.push par["headline"]
              arr.push par["description"]
              arr.push par["instruction"]
              arr.push par["effective"]
              arr.push par["expires"]
              arr.push par["severity"]
              arrN.push arr
              arr = []
            end
            unique = 1
        end
      end

    UserMailer.with(user: @driver.email, info: arrN, state: @state).alert_email.deliver_now
    end
  end
end

