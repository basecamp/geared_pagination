require 'test_helper'
require 'active_support/core_ext/array/access'
require 'geared_pagination/portions/portion_at_cursor'
require 'geared_pagination/order'

class GearedPagination::PortionAtCursorTest < ActiveSupport::TestCase
  ORDERS = [
    GearedPagination::Order.new(attribute: :number, direction: :desc),
    GearedPagination::Order.new(attribute: :id, direction: :desc)
  ]

  test "page number" do
    assert_equal 1, GearedPagination::PortionAtCursor.new(ordered_by: ORDERS).page_number
    assert_equal 2, GearedPagination::PortionAtCursor.new(
      cursor: GearedPagination::Cursor.new(page_number: 2), ordered_by: ORDERS).page_number
  end

  test "from" do
    create_recordings

    portion = GearedPagination::PortionAtCursor.new(ordered_by: ORDERS)
    assert_equal Recording.order(number: :desc, id: :desc).limit(15).to_a, portion.from(Recording.all).to_a

    portion = GearedPagination::PortionAtCursor.new \
      cursor: GearedPagination::Cursor.new(page_number: 2, values: { number: 106, id: 106 }), ordered_by: ORDERS
    assert_equal Recording.order(number: :desc, id: :desc).offset(15).limit(30).to_a, portion.from(Recording.all).to_a

    Recording.create number: 70

    portion = GearedPagination::PortionAtCursor.new \
      cursor: GearedPagination::Cursor.new(page_number: 3, values: { number: 76, id: 76 }), ordered_by: ORDERS
    assert_equal Recording.order(number: :desc, id: :desc).offset(45).limit(50).to_a, portion.from(Recording.all).to_a
  end

  test "with incomplete cursor" do
    create_recordings

    assert_equal Recording.order(number: :desc, id: :desc).limit(50).to_a,
      GearedPagination::PortionAtCursor.new(
        cursor: GearedPagination::Cursor.new(page_number: 3, values: { number: 76 }), ordered_by: ORDERS).from(Recording.all).to_a
  end

  test "with ordered scope" do
    assert_raises ArgumentError do
      GearedPagination::PortionAtCursor.new(ordered_by: ORDERS).from(Recording.order(id: :asc))
    end
  end

  test "with limited scope" do
    assert_raises ArgumentError do
      GearedPagination::PortionAtCursor.new(ordered_by: ORDERS).from(Recording.limit(100))
    end
  end

  test "next param" do
    create_recordings

    param = GearedPagination::PortionAtCursor.new(ordered_by: ORDERS).next_param(Recording.all)
    assert_equal GearedPagination::Cursor.encode(page_number: 2, values: { number: 106, id: 106 }), param

    param = GearedPagination::PortionAtCursor.new(
      cursor: GearedPagination::Cursor.decode(param), ordered_by: ORDERS).next_param(Recording.all)
    assert_equal GearedPagination::Cursor.encode(page_number: 3, values: { number: 76, id: 76 }), param

    param = GearedPagination::PortionAtCursor.new(
      cursor: GearedPagination::Cursor.decode(param), ordered_by: ORDERS).next_param(Recording.all)
    assert_equal GearedPagination::Cursor.encode(page_number: 4, values: { number: 26, id: 26 }), param
  end

  test "cache key changes according to current page and gearing" do
    assert_equal '2:3', cache_key(page: 2, per_page: 3)
    assert_equal '2:1-3', cache_key(page: 2, per_page: [ 1, 3 ])
    assert_equal '2:2-3', cache_key(page: 2, per_page: [ 2, 3 ])
  end

  private
    def cache_key(page:, per_page:)
      GearedPagination::PortionAtCursor.new(
        cursor: GearedPagination::Cursor.new(page_number: page),
        ordered_by: ORDERS,
        per_page: GearedPagination::Ratios.new(per_page)
      ).cache_key
    end
end
