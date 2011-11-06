require 'sinatra/activerecord/rake'
require 'rubygems'
require 'active_record'
require 'yaml'
require 'logger'

desc "Load the environment"
task :environment do
  env = ENV["RACK_ENV"] || "development"
  databases = YAML.load_file("config/database.yml")
  ActiveRecord::Base.establish_connection(databases[env])
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
    task :rollback => :environment do
      step = ENV['STEP'] ? ENV['STEP'].to_i : 1
      version = ActiveRecord::Migrator.current_version - step
      ActiveRecord::Migrator.migrate('db/migrate/', version)
  end
end