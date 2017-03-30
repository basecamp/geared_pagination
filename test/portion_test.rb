require 'test_helper'
require 'active_support/core_ext/array/access'
require 'geared_pagination/portion'

class GearedPagination::PortionTest < ActiveSupport::TestCase
  test "offset" do
    assert_equal 0, GearedPagination::Portion.new(page_number: 1).offset
    assert_equal GearedPagination::Ratios::DEFAULTS.first, GearedPagination::Portion.new(page_number: 2).offset
    assert_equal GearedPagination::Ratios::DEFAULTS.first + GearedPagination::Ratios::DEFAULTS.second, GearedPagination::Portion.new(page_number: 3).offset
  end

  test "limit" do
    assert_equal GearedPagination::Ratios::DEFAULTS.first, GearedPagination::Portion.new(page_number: 1).limit
    assert_equal GearedPagination::Ratios::DEFAULTS.second, GearedPagination::Portion.new(page_number: 2).limit
  end
end
