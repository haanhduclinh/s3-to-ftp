require_relative 'init'

class Main
  def initialize
    @s3 = S3Adapter.new(
      access_key_id,
      secret_access_key,
      region,
      bucket_name
    )
    @ftp = Ftp.new(
      host: @host,
      username: @username,
      password: @password,
      port: @port
    )
  end

  def run!
    maper_source.each do |source|
      file_path = "./config/#{source}"
      csv = CsvMap.new(file_path)
      csv.csv.each do |s3_and_ftp_path|
        aws_to_ftp(
          aws_key: s3_and_ftp_path[:aws_key],
          ftp_path: s3_and_ftp_path[:ftp_path]
        )
      end
    end
  end

  def aws_to_ftp(aws_key:, ftp_path:)
    local_file_path = "./tmp/#{ftp_path}"
    aws_to_local(aws_key, local_path: local_file_path)
    upload_to_ftp(local_file_path)
  end

  private

  def aws_to_local(aws_key, local_path:)
    @s3.download(aws_key, local_path: local_path)
  end

  def upload_to_ftp(local_file_path)
    @ftp.put(local_file_path)
  end

  def maper_source
    Settings.maper
  end

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
