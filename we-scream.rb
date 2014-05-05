require 'rest-client'
require 'json'
require 'addressable/uri'
require_relative 'secret.rb'
require 'nokogiri'

def my_location(address)
  Addressable::URI.new(
  :scheme => "https",
  :host => "maps.googleapis.com",
  :path => "/maps/api/geocode/json",
  :query_values => {
    :address => address,
    :sensor => false,
    :key => GOOGLE_KEY
  }
  ).to_s
end


def get_position(address = "770 Broadway New York NY")
  make_url = my_location(address)
  response = RestClient.get(make_url)
  location = JSON.parse(response)

  x = location["results"][0]["geometry"]["location"]["lat"]
  y = location["results"][0]["geometry"]["location"]["lng"]

  [x,y].join(',')
end


def my_ice_cream_search(arr)
  Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/nearbysearch/json",
    :query_values => {
      :location => arr,
      :rankby => :distance,
      #:types => "food",
      :keyword => "ice+cream",
      :sensor => false,
      :key => GOOGLE_KEY
    }
  ).to_s
end



def get_ice_cream(search_results)
  response = RestClient.get(search_results)
  options = JSON.parse(response)
  names = []
  x = 0
  options["results"].each do |shop|
    names << shop["name"]
  end
  names
end

def pull_coordinates(number, search_results)
  response = RestClient.get(search_results)
  options = JSON.parse(response)
  coord = options["results"][number]["geometry"]["location"]
  lat = coord["lat"]
  lng = coord["lng"]
  result = "#{lat}, #{lng}"
end

def meow_directions(there, here = get_position)
 # here is already done - from get_pos
  Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/directions/json",
    :query_values => {
      :origin => here,
      :destination => there,
      :sensor => false
    }
  ).to_s
end

def parse_directions(webness)
  response = RestClient.get(webness)
  options = JSON.parse(response)
  directions = []

  options["routes"][0]["legs"][0]["steps"].each do |direction|
    directions << direction["html_instructions"]
  end

  directions.map! do |dir|
    dir = Nokogiri::HTML(dir).text
  end

  directions
end

def get_stuff_done
  pos = get_position
  search = my_ice_cream_search(pos)
  shop_options = get_ice_cream(search)
  coords_of_shop = pull_coordinates(0, search)
  meow = meow_directions(coords_of_shop, pos)
end
