require_relative 'helper'
require './lib/ftp'

class TestFtp < Test::Unit::TestCase
  def setup
    @host = ::Settings.ftp.host
    @username = ::Settings.ftp.username
    @password = ::Settings.ftp.password
    @port = ::Settings.ftp.port

    @ftp = Ftp.new(
      host: @host,
      username: @username,
      password: @password,
      port: @port
    )
  end

  def test_valid_attribute
    assert_equal(@ftp.host, @host)
    assert_equal(@ftp.username, @username)
    assert_equal(@ftp.password, @password)
  end

  def test_list_all_file
    response = @ftp.list_all(type: :file)
    assert_equal(response.size > 10, true)
  end

  def test_upload_file_to_ftp
    file_path = './public/eric.jpg'
    @ftp.put(file_path)

    result = @ftp.exist?(File.basename(file_path))
    assert_equal(result, true)
  end

  def test_size
    @ftp.all
    assert_equal(@ftp.size.zero?, false)
  end

  def test_create_directory
    dirname = 'TEST_DIR'
    @ftp.create_directory(dirname)

    result = @ftp.exist?(File.basename(dirname))
    assert_equal(result, true)
  end
end
