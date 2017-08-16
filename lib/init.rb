require 'net/ftp'
require 'dotenv/load'
require 'config'
require_relative 'ftp'
require_relative 'csv_map'
require_relative 'aws_s3'
require './config/s3'
require './config/ftp'
require 'pry'

Config.load_and_set_settings(Config.setting_files('./config', ENV['ENV']))
