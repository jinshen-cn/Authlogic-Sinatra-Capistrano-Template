require 'sinatra'
require 'active_record'
require 'capistrano'
require 'authlogic'

require './lib/crypto.rb'

configure do
  env = ENV["RACK_ENV"] ||= 'development'  
  databases = YAML.load_file("config/database.yml")
  ActiveRecord::Base.establish_connection(databases[env])
  ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a'))
  #ActiveRecord::Base.logger = Logger.new(STDOUT)

  LOGGER = Logger.new("log/sinatra.log")
  enable :logging, :dump_errors
  set :raise_errors, true
end

error do
  e = request.env['sinatra.error']
  puts e.to_s
  puts e.backtrace.join("\n")
  "Application Error!"
end

# need to include the user after the database has been initialized in
# order for authlogic's acts_as_authentic to take effect
require './models/user'

class AccountsService < Sinatra::Base
  
  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['user', 'password']
    end
    
    def logger
      LOGGER
    end

    def format(data, format=params[:format], options={})
        case format
        when 'xml'
          data.to_xml options
        when 'json'
          data.to_json options
        else
          data.to_json options
        end
    end

  end
  
  # create a user login
  # curl http://localhost:9292/users -d "user[email]=a@b.com&user[password]=password&user[password_confirmation]=password"
  post '/users' do
    logger.info "Create a user."
    logger.info "PARAMS: #{params.inspect}"

    user = User.new
    user.update_attributes(params[:user])
    format(user)
  end

  # validate a user login and return the user object
  # curl http://localhost:9292/users/login -d "email=a@b.com&password=password"
  post '/users/login.?:format?' do
    # Uncomment to add basic http auth
    # protected!
    
    logger.info "Attempting to authenticate a user."
    logger.info "PARAMS: #{params.inspect}"
    
    # Initialize OptInPrompt variables to be saved
    email = params[:email]
    password = params[:password]
    
    user = User.find_by_email(email)
    if user
      password = password.gsub(" ", "+")
      begin
        # uncomment to have passwords passed in as encrypted.
        # decrypted_password = Crypto.decrypt(password)
        # if user.valid_password?(decrypted_password)
        
        if user.valid_password?(password)
          format(user)
        else
          format({ :status => 1001, :message => 'incorrect username or password' })
        end
      rescue
        format({ :status => 1003, :message => 'general exception' })
      end
    
    else
      format({ :status => 1002, :message => 'email address not found' })
    end
    
  end

end


