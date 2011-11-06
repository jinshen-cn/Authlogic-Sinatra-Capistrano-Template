require 'rubygems'
require 'bundler'

Bundler.setup

require './service_accounts.rb'

run AccountsService.new