require 'csv'

class CsvMap
  attr_accessor :csv

  def initialize(file)
    @csv = read_file(file)
  end

  def read_file(file)
    CSV.foreach(file, headers: true)
       .each_with_object([]) do |(aws_key, ftp_path), data|
      data << { aws_key: aws_key, ftp_path: ftp_path }
    end
  end
end
