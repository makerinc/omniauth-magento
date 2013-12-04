require 'omniauth/strategies/oauth'
require 'oauth/signature/plaintext'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      #args [:consumer_key, :consumer_secret, :site_id]
      
      option :client_options, {
        :access_token_path  => 'http://localhost/magento/oauth/token',
        :authorize_path     => 'http://localhost/magento/oauth/authorize',
        :request_token_path => 'http://localhost/magento/oauth/initiate',
        :scheme => :query_string,
      }
    end
  end
end
