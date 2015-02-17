$:.unshift File.expand_path '../lib', __FILE__
require 'barking_iguana/url_shortener'
c = BarkingIguana::UrlShortener::Client::Client.new
puts c.add 'http://example.com/'
