require 'omniauth/strategies/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      option :name, "magento"
      
      args[:consumer_key, :consumer_secret, :site]
      
      option :client_options, {
        :access_token_path  => "/oauth/token",
        :authorize_path     => "/oauth/authorize",
        :request_token_path => "/oauth/initiate",
        :site               => site # ENV["MAGENTO_URL"]
      }
      
      # set uid
      uid { raw_info.keys.first.to_i }

      # set additional info
      info do
        {
          'first_name' => raw_info.values.first["firstname"],
          'last_name' => raw_info.values.first["lastname"],
          'email' => raw_info.values.first["email"]
        }
      end

      # get info about current user
      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/api/rest/customers').body)
      end    
    end
  end
end
