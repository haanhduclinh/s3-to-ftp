require_relative 'helper'
require './lib/aws_s3'
require 'fileutils'

class TestAwsS3 < Test::Unit::TestCase
  def setup
    @s3_adapter = S3Adapter.new(
      access_key_id,
      secret_access_key,
      region, bucket
    ) do |config|
      config.client = Aws::S3::Client.new(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        region: region,
        endpoint: endpoint
      )
    end
  end

  def test_create_bucket
    @s3_adapter.create_bucket
    assert_kind_of(
      Seahorse::Client::Response,
      @s3_adapter.bucket_exists?(Settings.aws.s3.bucket_name)
    )
  end

  def test_copy_object_to_bucket
    local_path = './public/eric.jpg'
    response = @s3_adapter.put(local_path, Settings.aws.s3.bucket_name)
    assert_not_nil(response)
  end

  def test_valid_s3_bucket
    assert_equal(@s3_adapter.bucket_name, Settings.aws.s3.bucket_name)
  end

  def test_image_dowload
    @s3_adapter.download('eric.jpg')
    temp = './tmp/eric.jpg'
    assert_equal(File.exist?(temp), true)
    FileUtils.rm(temp)
  end

  private

  def bucket
    Settings.aws.s3.bucket_name
  end

  def access_key_id
    Settings.aws.s3.access_key_id
  end

  def secret_access_key
    Settings.aws.s3.secret_access_key
  end

  def region
    Settings.aws.s3.secret_access_key
  end

  def endpoint
    Settings.aws.s3.endpoint
  end
end
