require "barking_iguana/url_shortener/version"
require 'barking_iguana/verify'
require 'sinatra/base'
require 'rest-client'
require 'base_n'

module BarkingIguana
  module UrlShortener
    module Client
      class Client
        attr_accessor :public_key, :secret, :base_url
        def initialize public_key, secret, base_url: 'http://127.0.0.1:9292'
          self.public_key = public_key
          self.secret = secret
          self.base_url = base_url
        end

        def add target
          loop do
            now = BaseN::Number.new(Time.now.to_i.to_s, 10).rebase(58).to_s
            jitter = BaseN::Number.new(rand(1_000_000).to_s, 10).rebase(58).to_s
            code = "#{now}#{jitter}"
            intent = BarkingIguana::Verify::SignableAction.new 'PUT', "/#{code}", target: target
            action = intent.sign public_key, secret, Time.now + 10
            r = RestClient.put "#{base_url}#{action.signed_path.path}", action.signed_path.query_values
            return r.headers[:location] if r.code == 201
          end
        end
      end
    end

    module Server
      class Service < Sinatra::Base
        get '/:code' do
          code = params[:code]
          link = DB[:links].where(code: code).first!
          redirect link[:target]
        end

        def verify_signature! verb, path, request_params
          public_key = params.delete BarkingIguana::Verify::SignedAction::PARAMETER_PUBLIC_KEY.to_s
          signature = params.delete BarkingIguana::Verify::SignedAction::PARAMETER_SIGNATURE.to_s
          intent = BarkingIguana::Verify::SignableAction.new verb, path, request_params
          secret = DB[:accounts].where(public_key: public_key).get(:secret)
          intent.verify! signature, secret
        end

        put '/:code' do
          code = params[:code]
          verify_signature! 'PUT', "/#{code}", target: params[:target]
          DB[:links].insert code: code, target: params[:target]
          status 201
          headers "Location" => url("/#{code}")
        end
      end
    end
  end
end
