require_relative 'helper'
require './lib/main'

class TestMain < Test::Unit::TestCase
  def test_valid_config
    assert_equal(Settings.pixta.ftp.username, 'haanhduc')
  end
end