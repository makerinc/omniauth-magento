require 'omniauth/strategies/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      option :name, "magento"
      option :type, "customer"

binding.pry
      #if admin
        option :client_options, {
          :access_token_path  => "/oauth/token",
          :authorize_path     => "/oauth/authorize",
          :request_token_path => "/oauth/initiate"
        }
=begin      
      else
        option :client_options, {
          :access_token_path  => "/oauth/token",
          :authorize_path     => "/admin/oauth_authorize",
          :request_token_path => "/oauth/initiate",
        }
      end
=end      
      
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
