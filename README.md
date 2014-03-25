# Omniauth::Magento

An Omniauth strategy for Magento with detailed instructions on how to use it with Rails. Works only with the newer Magento REST api (not SOAP).

## Instructions on how to use with Rails

### Setting up Magento

#### Consumer key & secret

[Set up a consumer in Magento](http://www.magentocommerce.com/api/rest/authentication/oauth_configuration.html) and write down consumer key and consumer secret

#### Privileges

For the Customer API: In the Magento Admin backend, go to `System > Web Services > REST Roles`, select `Customer`, and tick `Retrieve` under `Customer`. Add more privileges as needed.

For the Admin API: In the Magento Admin backend, go to `System > Web Services > REST Roles`, select `Admin`, select `Admin API Resources`, select `Custom` in the `Resource Access` dropdown, tick `Retrieve` under `Customer`. Add more privileges as needed.

#### Attributes

For the Customer API: In the Magento Admin backend, go to `System > Web Services > REST Attributes`, select `Customer`, and tick `Email`, `First name` and `Last name` under `Customer` > `Read`. Add more attributes as needed.

For the Admin API: In the Magento Admin backend, go to `System > Web Services > REST Attributes`, select `Admin`, and tick `Email`, `First name` and `Last name` under `Customer` > `Read`. Add more attributes as needed.

#### Attributes

Only for the Admin API: In the Magento Admin backend, go to `System > Permissions > Users`, search for user who will be using this API, click on user, click on `User Role` and make sure `Administrator` is selected, click on `REST Role` and make sure `Admin` is selected.

### Setting up Rails

Parts of these instructions are based on these [OmniAuth instructions](https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview), which you can read in case you get stuck.

#### Devise

* Install [Devise](https://github.com/plataformatec/devise) if you haven't installed it
* Add / replace this line in your `routes.rb` `devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }`. This will be called once Magento has successfully authorized and returns to the Rails app.

#### Magento oAuth strategy

* Load this library into your Gemfile `gem "omniauth-magento"` and run `bundle install`
* Modify `config/initializers/devise.rb`:

```
Devise.setup do |config|
  # deactivate SSL on development environment
  OpenSSL::SSL::VERIFY_PEER ||= OpenSSL::SSL::VERIFY_NONE if Rails.env.development? 
  config.omniauth :magento,
    "ENTER_YOUR_MAGENTO_CONSUMER_KEY",
    "ENTER_YOUR_MAGENTO_CONSUMER_SECRET",
    { :client_options => { :site => "ENTER_YOUR_MAGENTO_URL_WITHOUT_TRAILING_SLASH" } }
  # example:
  # config.omniauth :magento, "12a3", "45e6", { :client_options =>  { :site => "http://localhost/magento" } }  
```

* optional: If you want to use the Admin API (as opposed to the Customer API), you need to overwrite the default `authorize_path` like so:

```
{ :client_options => { :authorize_path => "/admin/oauth_authorize", :site => ENTER_YOUR_MAGENTO_URL_WITHOUT_TRAILING_SLASH } }
```

* In your folder `controllers`, create a subfolder `users`
* In that subfolder `app/controllers/users/`, create a file `omniauth_callbacks_controller.rb` with the following code:

```
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def magento
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_magento_oauth(request.env["omniauth.auth"], current_user)

    if @user && @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "magento") if is_navigational_format?
    else
      session["devise.magento_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
end
```

#### User model & table

Here's an example of useful Magento information you can store in your `User` table once you have created these columns:
* `email`
* `first_name`
* `last_name`
* `magento_id`
* `magento_token`
* `magento_secret`

Optional: You might want to encrypt `magento_token` and `magento_secret` with the `attr_encrypted` gem for example (requires renaming `magento_token` to `encrypted_magento_token` and `magento_secret` to `encrypted_magento_secret`).

Set up your User model to be omniauthable `:omniauthable, :omniauth_providers => [:magento]` and create a method to save retrieved information after successfully authenticating. The method below can be shortened if only either the Customer API or the Admin API are used.

```
class User < ActiveRecord::Base  
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :timeoutable,
         :omniauthable, :omniauth_providers => [:magento]  

  def self.find_for_magento_oauth(auth, signed_in_resource=nil)    
    # update logged in user
    if signed_in_resource
      user = signed_in_resource
      update_user_with_magento_data(auth, user)
    # create new user if user details are known (not available through Admin API)
    elsif authenticated_through_customer_api?(auth)
      user = User.find_by(email: auth.info.email)
      if user
        update_user_with_magento_data(auth, user)
      else
        create_user_with_magento_data(auth)
      end
    # log authentication details from Magento if user details are not known (not signed in and authenticated through Admin API)
    else 
      puts "MAGENTO_TOKEN: #{magento_token}"
      puts "MAGENTO_SECRET: #{magento_secret}" 
    end
    user || nil
  end

private
  
  def self.authenticated_through_customer_api?(auth)
    auth.info.present?
  end

  def self.update_user_with_magento_data(auth, user)
    user.update!(
      magento_id: auth.try(:uid), # doesn't exist for Admin API
      magento_token: auth.credentials.token,
      magento_secret: auth.credentials.secret
    )
  end

  def self.create_user_with_magento_data(auth)
    user = User.create!(
      first_name: auth.info.first_name,                           
      last_name:  auth.info.last_name,
      magento_id: auth.uid,
      magento_token: auth.credentials.token,
      magento_secret: auth.credentials.secret,
      email:      auth.info.email,
      password:   Devise.friendly_token[0,20]
    )
  end          
end
```

#### Link to start authentication

Add this line to your view `<%= link_to "Sign in with Magento", user_omniauth_authorize_path(:magento) %>`

### Authenticating

* Start your Rails server
* Start your Magento server
* Log into Magento with a customer (not admin) account
* In your Rails app, go to the view where you pasted this line `<%= link_to "Sign in with Magento", user_omniauth_authorize_path(:magento) %>`
* Click on the link
* You now should be directed to a Magento view where you are prompted to authorize access to the Magento user account
* Once you have confirmed, you should get logged into Rails and redirected to the Rails callback URL specified above. The user should now have `magento_id`, `magento_token` and `magento_secret` stored.

### Making API calls

* Create a class that uses `magento_token` and `magento_secret` to do API calls for instance in `lib/magento_inspector.rb`. Example:
```
class MagentoInspector
  require "oauth"
  require "omniauth"
  require "multi_json"

  def initialize
    @access_token = prepare_access_token(current_user) # or pass user in initialize method 
    @response = MultiJson.decode(@access_token.get("/api/rest/customers").body) # or pass query in initialize method, make sure privileges and attributes are enabled for query (see section at top)
  end

private

  # from http://behindtechlines.com/2011/08/using-the-tumblr-api-v2-on-rails-with-omniauth/
  def prepare_access_token(user)
    consumer = OAuth::Consumer.new("ENTER_YOUR_MAGENTO_CONSUMER_KEY", "ENTER_YOUR_MAGENTO_CONSUMER_SECRET", {:site => "ENTER_YOUR_MAGENTO_URL_WITHOUT_TRAILING_SLASH"})
    token_hash = {:oauth_token => user.magento_token, :oauth_token_secret => user.magento_secret}
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash)
  end
end
```
* Make sure Rails loads files in the folder where this class is placed. For the `lib` folder, put this in `config/application.rb`: `config.autoload_paths += Dir["#{config.root}/lib/**/"]`
* Perform query `MagentoInspector.new`
* Extend class to suit your needs
