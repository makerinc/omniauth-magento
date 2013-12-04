require 'omniauth/strategies/oauth'
require 'oauth/signature/plaintext'

module OmniAuth
  module Strategies
    class Magento < OmniAuth::Strategies::OAuth
      #args [:consumer_key, :consumer_secret, :site_id]
      
      option :client_options, {
        :access_token_path  => 'http://ec2-54-252-90-6.ap-southeast-2.compute.amazonaws.com/oauth/token',
        :authorize_path     => 'http://ec2-54-252-90-6.ap-southeast-2.compute.amazonaws.com/oauth/authorize',
        :request_token_path => 'http://ec2-54-252-90-6.ap-southeast-2.compute.amazonaws.com/oauth/initiate',
        :scheme => :query_string,
        :oauth_callback => "oob"
      }
    end
  end
end
