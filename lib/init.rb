require 'net/ftp'
require 'dotenv/load'
require 'config'
require_relative 'ftp'

Config.load_and_set_settings(Config.setting_files('./config', ENV['ENV']))
