require 'omniauth/strategies/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      # Give your strategy a name.
      option :name, "magento"
      
      option :client_options, {
        :access_token_path  => "/oauth/token",
        :authorize_path     => "/oauth/authorize",
        :request_token_path => "/oauth/initiate",
        :site               => ENV["MAGENTO_URL"]
      }
      
      # set uid
      uid { raw_info.id }

      # set additional info
      info do
        {
          'first_name' => raw_info.firstname,
          'last_name' => raw_info.lastname,
          'email' => raw_info.email
        }
      end

      # get info about current user
      def raw_info
        @raw_info ||= MultiJson.decode(access_token.get('/api/rest/customers').body)
        binding.pry
      end    
    end
  end
end
