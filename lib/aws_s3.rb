require 'aws-sdk'

class S3Adapter
  attr_accessor :bucket_name, :client

  def initialize(access_key_id, secret_access_key, region, bucket_name)
    @bucket_name = bucket_name
    @client = Aws::S3::Client.new(
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      region: region
    )
    yield(self) if block_given?
  end

  def download(key, local_path: nil)
    local_file_name = if local_path
                        local_path
                      else
                        "./tmp/#{File.basename(key)}"
                      end

    File.open(local_file_name, 'wb') do |file|
      @client.get_object(bucket: bucket_name, key: key) do |chunk|
        file.write(chunk)
      end
    end
  end

  def create_bucket
    @client.create_bucket(bucket: bucket_name)
  end

  def bucket_exists?(bucket)
    @client.head_bucket(bucket: bucket)
  end

  def put(local_path, bucket)
    res = @client.put_object(
      body: local_path,
      bucket: bucket,
      key: File.basename(local_path)
    )
    res[:etag]
  end
end
