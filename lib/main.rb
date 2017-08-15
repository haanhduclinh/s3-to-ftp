require_relative 'init'

class Main
  attr_accessor :s3, :ftp
  include Config::S3
  include Config::Ftp

  def initialize
    @s3 = S3Adapter.new(s3_args)
    @ftp = Ftp.new(
      host: host,
      username: username,
      password: password,
      port: port
    )
    yield(self) if block_given?
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

    true
  end

  def aws_to_ftp(aws_key:, ftp_path:)
    local_file_path = "./tmp/#{ftp_path}"
    aws_to_local(aws_key, local_path: local_file_path)
    upload_to_ftp(local_file_path)
  end

  private

  def s3_args
    {
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
      region: region,
      bucket_name: bucket_name
    }
  end

  def aws_to_local(aws_key, local_path:)
    @s3.download(aws_key, local_path: local_path)
  end

  def upload_to_ftp(local_file_path)
    @ftp.put(local_file_path)
  end

  def maper_source
    Settings.maper
  end
end
