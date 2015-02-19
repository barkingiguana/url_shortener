require 'sequel'
ENV['DATABASE_URL'] ||= 'sqlite::memory:'
DB = Sequel.connect ENV['DATABASE_URL']
require 'logger'
DB.loggers << Logger.new($stdout)
DB.loggers.each { |l| l.level = Logger::DEBUG }
DB.create_table? :links do
  primary_key :id
  String :code # TODO: Add a unique constraint to this
  String :target
end
DB.create_table? :accounts do
  primary_key :id
  String :public_key # TODO: Add a unique constraint to this
  String :secret
end
DB[:accounts].insert public_key: 'example', secret: 'Thi|niemC/ivah9_dEicaiwim3'
$:.unshift File.expand_path '../lib', __FILE__
require 'barking_iguana/url_shortener'
run BarkingIguana::UrlShortener::Server::Service
