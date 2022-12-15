require 'aws-sdk-s3'
require 'fileutils'

class S3Adapter
  attr_accessor :bucket_name, :client

  def initialize(args = {})
    @bucket_name = args[:bucket_name]
    @client = s3_client(args) unless args.empty?
    yield(self) if block_given?
  end

  def download(key, local_path: nil)
    local_file_name = if local_path
                        local_path
                      else
                        "./tmp/#{File.basename(key)}"
                      end

    create_directory_if_none_exsits(local_file_name)
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

  private

  def s3_client(args)
    Aws::S3::Client.new(
      access_key_id: args[:access_key_id],
      secret_access_key: args[:secret_access_key],
      region: args[:region]
    )
  end

  def create_directory_if_none_exsits(path)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
  end
end
