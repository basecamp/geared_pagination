require 'test_helper'
require 'geared_pagination/order'

class GearedPagination::OrderTest < ActiveSupport::TestCase
  test "invalid direction" do
    error = assert_raises(ArgumentError) { GearedPagination::Order.new(attribute: :number, direction: nil) }
    assert_equal "Invalid direction for order on :number: expected :asc or :desc, got nil", error.message
  end

  test "asc?" do
    assert GearedPagination::Order.new(attribute: :number, direction: :asc).asc?
    assert_not GearedPagination::Order.new(attribute: :number, direction: :desc).asc?
  end

  test "desc?" do
    assert_not GearedPagination::Order.new(attribute: :number, direction: :asc).desc?
    assert GearedPagination::Order.new(attribute: :number, direction: :desc).desc?
  end

  test "wrap many" do
    assert_equal [ GearedPagination::Order.new(attribute: :number) ], GearedPagination::Order.wrap_many(:number)

    assert_equal \
      [ GearedPagination::Order.new(attribute: :number), GearedPagination::Order.new(attribute: :id) ],
      GearedPagination::Order.wrap_many([ :number, :id ])

    assert_equal [ GearedPagination::Order.new(attribute: :number, direction: :desc) ],
      GearedPagination::Order.wrap_many(number: :desc)

    assert_equal \
      [ GearedPagination::Order.new(attribute: :number), GearedPagination::Order.new(attribute: :id, direction: :desc) ],
      GearedPagination::Order.wrap_many([ :number, id: :desc ])
  end
end
