require 'test_helper'
require 'geared_pagination/recordset'

class GearedPagination::RecordsetTest < ActiveSupport::TestCase
  setup :create_recordings

  test "single limit pagination by offset" do
    recordset = GearedPagination::Recordset.new(Recording.all, per_page: 10)
    assert_equal 10, recordset.page(1).records.size
    assert_equal 10, recordset.page(2).records.size
  end

  test "variable limit pagination by offset" do
    recordset = GearedPagination::Recordset.new(Recording.all, per_page: [ 10, 15, 20 ])

    assert_equal 10, recordset.page(1).records.size
    assert recordset.page(1).records.include?(Recording.all[0])

    assert_equal 15, recordset.page(2).records.size
    assert recordset.page(2).records.include?(Recording.all[11])

    assert_equal 20, recordset.page(3).records.size
    assert recordset.page(3).records.include?(Recording.all[26])

    assert_equal 20, recordset.page(4).records.size
    assert recordset.page(4).records.include?(Recording.all[46])
  end

  test "single limit pagination by cursor" do
    recordset = GearedPagination::Recordset.new Recording.all, ordered_by: :number, per_page: 10

    cursor = GearedPagination::Cursor.encode(page_number: 1)
    assert_equal 10, recordset.page(cursor).records.size

    cursor = GearedPagination::Cursor.encode(page_number: 2, values: { number: 10 })
    assert_equal 10, recordset.page(cursor).records.size

    cursor = GearedPagination::Cursor.encode(page_number: 3, values: { number: 20 })
    assert_equal 10, recordset.page(cursor).records.size
  end

  test "variable limit pagination by cursor" do
    recordset = GearedPagination::Recordset.new Recording.all, ordered_by: [ :number, :id ], per_page: [ 10, 15, 20 ]

    cursor = GearedPagination::Cursor.encode(page_number: 1)
    assert_equal 10, recordset.page(cursor).records.size
    assert_equal 1, recordset.page(cursor).records.first.number
    assert_equal 10, recordset.page(cursor).records.last.number

    cursor = GearedPagination::Cursor.encode(page_number: 2, values: { number: 10, id: 10 })
    assert_equal 15, recordset.page(cursor).records.size
    assert_equal 11, recordset.page(cursor).records.first.number
    assert_equal 25, recordset.page(cursor).records.last.number

    cursor = GearedPagination::Cursor.encode(page_number: 3, values: { number: 25, id: 25 })
    assert_equal 20, recordset.page(cursor).records.size
    assert_equal 26, recordset.page(cursor).records.first.number
    assert_equal 45, recordset.page(cursor).records.last.number

    cursor = GearedPagination::Cursor.encode(page_number: 4, values: { number: 45, id: 45 })
    assert_equal 20, recordset.page(cursor).records.size
    assert_equal 46, recordset.page(cursor).records.first.number
    assert_equal 65, recordset.page(cursor).records.last.number
  end

  test "page count" do
    assert_equal 7, GearedPagination::Recordset.new(Recording.all, per_page: [ 10, 15, 20 ]).page_count
  end

  test "records count" do
    assert_equal Recording.all.count, GearedPagination::Recordset.new(Recording.all, per_page: [ 10, 15, 20 ]).records_count
  end

  test "unscope select for count" do
    select_scoped_records = Recording.all.select(:id, :number)
    recordset = GearedPagination::Recordset.new(select_scoped_records, per_page: [ 10, 15, 20 ])
    assert_equal Recording.all.count, recordset.records_count
  end
end
