require_relative '../helper'
require './lib/csv_map'

class TestCsvMap < Test::Unit::TestCase
  def setup
    file_path = "./config/#{Settings.maper.first}"
    @map = CsvMap.new(file_path)
  end

  def test_load_csv_success
    assert_equal(@map.csv.size.zero?, false)
  end
end
