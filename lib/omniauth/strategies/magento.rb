require 'omniauth/strategies/oauth'
require 'oauth/signature/plaintext'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      option :client_options, {
        :access_token_path  => 'localhost:8888/magento/oauth/token',
        :authorize_path     => 'localhost:8888/magento//admin/oauth_authorize',
        :request_token_path => 'localhost:8888/magento//oauth/initiate',
        :signature_method   => 'PLAINTEXT'
      }
    end
  end
end
