require 'omniauth/strategies/oauth'
require 'oauth/signature/plaintext'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      #args [:consumer_key, :consumer_secret, :site_id]
      
      option :client_options, {
        :access_token_path  => '/oauth/token',
        :authorize_path     => '/oauth/authorize',
        :request_token_path => '/oauth/initiate',
        :signature_method   => 'PLAINTEXT',
        :side_id => "http://localhost:8888/magento"
      }
    end
  end
end
