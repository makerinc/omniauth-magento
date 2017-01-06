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
            
      # when calling Customer (not Admin) API, Magento returns user credentials for logged in Magento user
      # these credentials can then be used to create a new user in the Rails app
      # won't work with Admin API since /customers will return all customers

      def customer_role_auth?
        options.client_options.authorize_path == "/oauth/authorize"
      end

      def customer_info_hash
        return {} unless raw_info.try(:values).try(:first).present?
        {
          'first_name' => raw_info.values.first["firstname"],
          'last_name' => raw_info.values.first["lastname"],
          'email' => raw_info.values.first["email"]            
        }
      end

      uid do
        customer_role_auth? ? raw_info.try(:keys).try(:first).try(:to_i) : {}
      end      

      # set additional info
      info do
        customer_role_auth? ? customer_info_hash : {}
      end

      # get info about current user
      def raw_info
        return unless customer_role_auth?
        @raw_info ||= MultiJson.decode(access_token.get('/api/rest/customers').body)
      end              
    end
  end
end
