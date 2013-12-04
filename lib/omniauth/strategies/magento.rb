require 'omniauth/strategies/oauth'
require 'oauth/signature/plaintext'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth

      #args [:consumer_key, :consumer_secret, :site]
      
      option :client_options, {
        :access_token_path  => 'oauth/token',
        :authorize_path     => 'oauth/authorize',
        :request_token_path => 'oauth/initiate',
        :scheme => :query_string
      }
    end
  end
end
