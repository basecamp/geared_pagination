require 'test_helper'
require 'geared_pagination/cursor'

class GearedPagination::CursorTest < ActiveSupport::TestCase
  test "from empty param" do
    assert_equal 1, GearedPagination::Cursor.from_param(nil).page_number
    assert_equal 1, GearedPagination::Cursor.from_param(" ").page_number
  end

  test "from an invalid param" do
    assert_equal 1, GearedPagination::Cursor.from_param("aGVsbG8K").page_number
    assert_equal 1, GearedPagination::Cursor.from_param("\o/ not base64").page_number
  end

  test "decode" do
    assert_equal 1, GearedPagination::Cursor.decode("eyJwYWdlX251bWJlciI6MX0=").page_number
  end

  test "encode" do
    assert_equal "eyJwYWdlX251bWJlciI6MSwidmFsdWVzIjp7fX0=", GearedPagination::Cursor.encode(page_number: 1)
    assert_equal "eyJwYWdlX251bWJlciI6MSwidmFsdWVzIjp7Im51bWJlciI6MTAwfX0=", GearedPagination::Cursor.encode(page_number: 1, values: { number: 100 })
  end

  test "page number" do
    assert_equal 1, GearedPagination::Cursor.new(page_number: 0).page_number
    assert_equal 1, GearedPagination::Cursor.new(page_number: 1).page_number
    assert_equal 2, GearedPagination::Cursor.new(page_number: 2).page_number
  end

  test "fetch" do
    assert_equal 100, GearedPagination::Cursor.new(page_number: 1, values: { number: 100 }).fetch(:number)
  end

  test "include?" do
    cursor = GearedPagination::Cursor.new(page_number: 1, values: { number: 100 })
    assert cursor.include?(:number)
    assert_not cursor.include?(:foo)
  end
end
