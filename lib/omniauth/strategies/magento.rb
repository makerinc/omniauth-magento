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
      
      uid { raw_info.id }

      info do
        {
          'name' => raw_info.name,
          'username' => raw_info.username,
        }
      end

      extra do
        { :raw_info => raw_info }
      end

      def raw_info
        require 'pry'; binding.pry
        #@raw_info ||= MultiJson.decode(access_token.get('/1/account/info').body)
        #access_token.options[:parse] = :json

        ## This way is not working right now, do it the longer way
        ## for the time being

        ##@raw_info ||= access_token.get('/ap/user/profile').parsed

        #url = :sit_id
        #params = {:params => { :access_token => access_token.token}}
        #@raw_info ||= access_token.client.request(:get, url, params).parsed
      end
    end
  end
end
