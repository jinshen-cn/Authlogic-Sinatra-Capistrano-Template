# Load application configuration
require 'ostruct'
require 'yaml'
 
config = YAML.load_file("./config/brave.yml") || {}
app_config = config['common'] || {}
env = ENV["RACK_ENV"] || "development"
app_config.update(config[env] || {})
AppConfig = OpenStruct.new(app_config)