# ENV=production-vn START=1 BUCKET_NAME=xxx MAPER=output_20.csv ruby script/s3_to_ftp.rb
require './lib/main.rb'

start_point = ENV["START"].to_i
Main.new.run!(start_point: start_point)