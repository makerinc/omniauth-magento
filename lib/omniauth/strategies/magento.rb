require 'omniauth/strategies/oauth'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      # Give your strategy a name.
      option :name, "magento"
      
      option :client_options, {
        :access_token_path  => "oauth/token",
        :authorize_path     => "oauth/authorize",
        :request_token_path => "oauth/initiate",
        :site_id            => "http://localhost/magento/"
      }
    end
  end
end
