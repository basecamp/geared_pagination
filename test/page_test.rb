require 'test_helper'
require 'geared_pagination/recordset'

class GearedPagination::PageTest < ActiveSupport::TestCase
  setup :create_recordings

  test "first" do
    assert GearedPagination::Recordset.new(Recording.all).page(1).first?
    assert_not GearedPagination::Recordset.new(Recording.all).page(2).first?
  end

  test "only" do
    assert     GearedPagination::Recordset.new(Recording.all, per_page: 1000).page(1).only?
    assert_not GearedPagination::Recordset.new(Recording.all, per_page:    1).page(1).only?
  end

  test "last" do
    assert     GearedPagination::Recordset.new(Recording.all, per_page: 1000).page(1).last?
    assert_not GearedPagination::Recordset.new(Recording.all, per_page:    1).page(1).last?
  end

  test "last with page number greater than page count" do
    assert_not GearedPagination::Recordset.new(Recording.none, per_page: 1000).page(2).last?
  end

  test "before_last" do
    assert     GearedPagination::Recordset.new(Recording.all, per_page:    1).page(1).before_last?
    assert_not GearedPagination::Recordset.new(Recording.all, per_page: 1000).page(1).before_last?
    assert_not GearedPagination::Recordset.new(Recording.none, per_page: 1000).page(2).before_last?
  end

  test "next offset param" do
    assert_equal 2, GearedPagination::Recordset.new(Recording.all, per_page: 1000).page(1).next_param
  end

  test "next cursor param" do
    assert_equal GearedPagination::Cursor.encode(page_number: 2, values: { number: 15 }),
      GearedPagination::Recordset.new(Recording.all, ordered_by: :number, per_page: 15)
        .page(GearedPagination::Cursor.encode(page_number: 1)).next_param
  end

  test "next number" do
    assert_deprecated do
      assert_equal 2, GearedPagination::Recordset.new(Recording.all, per_page: 1000).page(1).next_number
    end
  end

  test "with empty recordset" do
    page_for_empty_set = GearedPagination::Recordset.new(Recording.none, per_page: 1000).page(1)

    assert page_for_empty_set.first?
    assert page_for_empty_set.only?
    assert page_for_empty_set.last?
  end

  test "cache key changes according to current page and gearing" do
    assert_equal 'page/2:3', cache_key(page: 2, per_page: 3)
    assert_equal 'page/2:1-3', cache_key(page: 2, per_page: [ 1, 3 ])
    assert_equal 'page/2:2-3', cache_key(page: 2, per_page: [ 2, 3 ])
  end

  private
    def cache_key(page:, per_page:)
      GearedPagination::Recordset.new(Recording.all, per_page: per_page).page(page).cache_key
    end
end
