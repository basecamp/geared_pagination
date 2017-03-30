require 'test_helper'
require 'geared_pagination/recordset'

class GearedPagination::RecordsetTest < ActiveSupport::TestCase
  test "single limit pagination" do
    collection = GearedPagination::Recordset.new(Recording.all, per_page: 10)

    assert_equal 10, collection.page(1).records.size
    assert_equal 10, collection.page(2).records.size
  end

  test "variable limit pagination" do
    collection = GearedPagination::Recordset.new(Recording.all, per_page: [ 10, 15, 20 ])

    assert_equal 10, collection.page(1).records.size
    assert collection.page(1).records.include?(Recording.all[0])

    assert_equal 15, collection.page(2).records.size
    assert collection.page(2).records.include?(Recording.all[11])

    assert_equal 20, collection.page(3).records.size
    assert collection.page(3).records.include?(Recording.all[26])

    assert_equal 20, collection.page(4).records.size
    assert collection.page(4).records.include?(Recording.all[46])
  end

  test "page count" do
    assert_equal 7, GearedPagination::Recordset.new(Recording.all, per_page: [ 10, 15, 20 ]).page_count
  end

  test "records count" do
    assert_equal Recording.all.count, GearedPagination::Recordset.new(Recording.all, per_page: [ 10, 15, 20 ]).records_count
  end
end
