require 'sequel'
ENV['DATABASE_URL'] ||= 'sqlite::memory:'
DB = Sequel.connect ENV['DATABASE_URL']
require 'logger'
DB.loggers << Logger.new($stdout)
DB.loggers.each { |l| l.level = Logger::DEBUG }
DB.create_table? :links do
  primary_key :id
  String :code
  String :target
end
$:.unshift File.expand_path '../lib', __FILE__
require 'barking_iguana/url_shortener'
run BarkingIguana::UrlShortener::Server::Service
