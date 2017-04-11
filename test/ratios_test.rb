require 'test_helper'
require 'geared_pagination/ratios'

class GearedPagination::RatiosTest < ActiveSupport::TestCase
  test "single limit" do
    limits = GearedPagination::Ratios.new(10)

    assert_equal 10, limits[1]
    assert_equal 10, limits[2]
  end

  test "range of limits" do
    limits = GearedPagination::Ratios.new([ 10, 25, 100 ])

    assert_equal 10, limits[1]
    assert_equal 25, limits[2]
    assert_equal 100, limits[3]
    assert_equal 100, limits[4]
  end

  test "default limits" do
    limits = GearedPagination::Ratios.new

    assert_equal GearedPagination::Ratios::DEFAULTS.first, limits[1]
    assert_equal GearedPagination::Ratios::DEFAULTS.last, limits[99]
  end

  test "cache key" do
    assert_equal "1-2-3", GearedPagination::Ratios.new([ 1, 2, 3 ]).cache_key
  end
end
