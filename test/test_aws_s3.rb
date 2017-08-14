require_relative 'helper'
require "./lib/aws_s3"

class TestAwsS3 < Test::Unit::TestCase
  def setup
    bucket = Settings.pixta.aws.s3.bucket_name
    access_key_id = Settings.pixta.aws.s3.access_key_id
    secret_access_key = Settings.pixta.aws.s3.secret_access_key
    region = Settings.pixta.aws.s3.region
    endpoint = Settings.pixta.aws.s3.endpoint

    @s3_adapter = S3Adapter.new(access_key_id, secret_access_key, region, bucket) do |config|
      config.client = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        region: region,
        endpoint: endpoint,
      )
    end
  end

  def test_create_bucket
    @s3_adapter.create_bucket
    assert_kind_of(Seahorse::Client::Response, @s3_adapter.bucket_exists?(Settings.pixta.aws.s3.bucket_name))
  end

  def test_put_object
    local_path = './public/eric.jpg'
    response = @s3_adapter.put(local_path, Settings.pixta.aws.s3.bucket_name)
    assert_not_nil(response)
  end

  def test_dowload
    response = @s3_adapter.download('eric.jpg')
    assert_equal(File.exist?('./tmp/eric.jpg'), true)
  end

  def test_valid_s3_bucket
    assert_equal(@s3_adapter.bucket_name, Settings.pixta.aws.s3.bucket_name, "It should be the same")    
  end
end
