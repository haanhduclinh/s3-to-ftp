require 'csv'

class CsvMap
  attr_accessor :csv

  def initialize(file)
    @csv = read_file(file)
  end

  def read_file(file)
    CSV.foreach(file, headers: true)
       .each_with_object([]) do |row, data|
      data << { aws_key: row['aws_key'], ftp_path: row['ftp_path'] }
    end
  end
end
