require 'omniauth/strategies/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      option :name, "magento"

      option :client_options, {
        :request_token_path => "/oauth/initiate",          
        :authorize_path     => "/oauth/authorize",          
        :access_token_path  => "/oauth/token"
      }
      
      # set uid
      uid { raw_info.keys.first.to_i }

      # set additional info
      info do
        if options[:client_options][:authorize_path] == "/oauth/authorize"
          {
            'first_name' => raw_info.values.first["firstname"],
            'last_name' => raw_info.values.first["lastname"],
            'email' => raw_info.values.first["email"],
            'info' => raw_info
          }
        end
      end

      # get info about current user
      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/api/rest/customers').body)
      end    
    end
  end
end
