require_relative 'init'

class Main
  attr_accessor :s3, :ftp
  include Config::S3
  include Config::Ftp
  include Config::Slack

  def initialize
    init_s3_and_ftp
    yield(self) if block_given?
  end

  def run!(start_point: 0)
    maper_source.each do |source|
      file_path = "./config/#{source}"
      csv = CsvMap.new(file_path)

      max_file = csv.csv.size - 1
      for index in start_point..max_file
        s3_and_ftp_path = csv.csv[index]
        display_bar(max_file, index + 1, s3_and_ftp_path)
        aws_to_ftp(
          aws_key: s3_and_ftp_path[:aws_key],
          ftp_path: s3_and_ftp_path[:ftp_path]
        )
      end
    end

    true
  rescue => e
    send_to_lack(e.message, ENV["HOSTNAME"] || 'UNKNOW PC')
    p e.message
  end

  def aws_to_ftp(aws_key:, ftp_path:)
    local_file_path = "./tmp/#{ftp_path}"
    aws_to_local(aws_key, local_path: local_file_path)
    upload_to_ftp(local_file_path)
  rescue => _e
    p "Time: #{Time.now} | we have error: #{_e.message} | begin retry"
    sleep(3)
    init_s3_and_ftp
    aws_to_ftp(aws_key: aws_key, ftp_path: ftp_path)
  end

  private

  def init_s3_and_ftp
    @s3 = S3Adapter.new(s3_args)
    @ftp = Ftp.new(
      host: host,
      username: username,
      password: password,
      port: port
    )
  end

  def display_bar(total, current, path)
    current_percent = (current * 100 / total).round
    message = "Time: #{Time.now} | Total: #{total} | Current: #{current} | Percent: #{current_percent}% | #{path}"
    send_to_lack(message, ENV["NAME"])
  end

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
    FileUtils.rm(local_file_path)
  end

  def maper_source
    Settings.maper
  end
end
