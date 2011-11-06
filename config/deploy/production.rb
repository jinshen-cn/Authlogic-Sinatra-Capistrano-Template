set :application, "yourapp.yourdomain.com"
set :deploy_to, "/data/web/your_app_folder"
set :user, "username"
set :rails_env, "production"
set :migrate_env, "RACK_ENV=production"
set :branch, "master"
set :use_sudo, false

server "127.0.0.1", :web, :app, :db, :primary => true

