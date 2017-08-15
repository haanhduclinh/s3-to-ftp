require 'ftpd'
require 'tmpdir'

class Driver
  def initialize(temp_dir)
    @temp_dir = temp_dir
  end

  def authenticate(_user, _password)
    true
  end

  def file_system(_user)
    Ftpd::DiskFileSystem.new(@temp_dir)
  end
end

Dir.mktmpdir do |temp_dir|
  driver = Driver.new(temp_dir)
  server = Ftpd::FtpServer.new(driver)
  server.start
  File.open('./tmp/pid/test.pid', 'w') { |file| file.write(server.bound_port) }
  puts "Server listening on port #{server.bound_port}"
  gets
end
