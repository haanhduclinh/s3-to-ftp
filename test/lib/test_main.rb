require_relative '../helper'
require './lib/main'

class TestMain < Test::Unit::TestCase
  include Config::S3
  include Config::Ftp

  def setup
    @m = Main.new do |config|
      client = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        region: region,
        endpoint: endpoint
      )

      s3_adapter = S3Adapter.new do |c|
        c.client = client
        c.bucket_name = bucket_name
      end

      config.s3 = s3_adapter
    end
  end

  def test_valid_config
    assert_equal(Settings.ftp.username, 'anonymous')
  end

  def test_progress
    assert_equal(@m.run!, true)
  end
end
