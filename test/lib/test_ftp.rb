require_relative '../helper'
require './lib/ftp'

class TestFtp < Test::Unit::TestCase
  include Config::Ftp

  def setup
    @ftp = Ftp.new(
      host: host,
      username: username,
      password: password,
      port: port
    )
  end

  def test_valid_attribute
    assert_equal(@ftp.host, host)
    assert_equal(@ftp.username, username)
    assert_equal(@ftp.password, password)
  end

  def test_upload_file_to_ftp
    file_path = './public/eric.jpg'
    @ftp.put(file_path)

    result = @ftp.exist?(file_path)
    assert_equal(result, true)
  end

  def test_size
    @ftp.all
    assert_equal(@ftp.size.zero?, false)
  end

  def test_create_directory
    dirname = 'TEST_DIR'
    @ftp.create_directory(dirname) unless @ftp.exist?(dirname)

    result = @ftp.exist?(File.basename(dirname))
    assert_equal(result, true)
  end

  def test_method_check_sub_folder
    example = 'public/eric.jp'
    assert_equal(@ftp.send(:sub_folder?, example), false)
    example = 'public/images/eric.jp'
    assert_equal(@ftp.send(:sub_folder?, example), true)
  end

  def test_list_all
    assert_equal(@ftp.list_all.size.positive?, true)
    assert_equal(@ftp.list_all(type: :folder).size.positive?, true)
    assert_equal(@ftp.list_all(type: :file).size.positive?, true)
  end

  def test_method_check_has_parent_folder
    example = 'public/eric.jp'
    assert_equal(@ftp.send(:parent_folder?, example), true)
  end

  def test_delele_method
    file_path = 'public/eric.jpg'
    @ftp.put(file_path)
    @ftp.delete(file_path)

    result = @ftp.exist?(file_path)
    assert_equal(result, false)
  end
end
