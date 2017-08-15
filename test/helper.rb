require 'coveralls'
Coveralls.wear!
require 'dotenv/load'
require 'config'
require 'test/unit'
require 'pry'

Config.load_and_set_settings(Config.setting_files('./config', ENV['ENV']))
