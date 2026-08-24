require 'test_helper'
require 'active_support/core_ext/string/inquiry'
require 'geared_pagination/headers'
require 'geared_pagination/recordset'

class GearedPagination::HeadersTest < ActiveSupport::TestCase
  Request    = Struct.new(:url, :format)
  Controller = Struct.new(:request, :headers)

  setup do
    create_recordings

    @controller_serving_json = Controller.new(Request.new("http://example.com/recordset.json", "json".inquiry), {})
    @controller_serving_html = Controller.new(Request.new("http://example.com/recordset", "html".inquiry), {})

    @single_page_recordset = GearedPagination::Recordset.new(Recording.all, per_page: 1000)
    @many_page_recordset   = GearedPagination::Recordset.new(Recording.all, per_page: 1)
  end

  test "total count with custom cursor name" do
    GearedPagination::Headers.new(page: @many_page_recordset.page(1), controller: @controller_serving_json).apply
    assert_equal Recording.all.count.to_s, @controller_serving_json.headers["X-Total-Count"]
  end

  test "no link for html requests with custom cursor name" do
    GearedPagination::Headers.new(page: @many_page_recordset.page(1), controller: @controller_serving_html).apply
    assert @controller_serving_html.headers["Link"].nil?
  end

  test "no link for json request with single page with custom cursor name" do
    GearedPagination::Headers.new(page: @single_page_recordset.page(1), controller: @controller_serving_json).apply
    assert @controller_serving_html.headers["Link"].nil?
  end

  test "links for json request with multiple pages with custom cursor name" do
    begin
      GearedPagination.configure do |config|
        config.cursor_name = :cursor
      end

      GearedPagination::Headers.new(page: @many_page_recordset.page(1), controller: @controller_serving_json).apply
      assert_equal '<http://example.com/recordset.json?cursor=2>; rel="next"',
        @controller_serving_json.headers["Link"]

      GearedPagination::Headers.new(page: @many_page_recordset.page(2), controller: @controller_serving_json).apply
      assert_equal '<http://example.com/recordset.json?cursor=3>; rel="next"',
        @controller_serving_json.headers["Link"]
    ensure
      GearedPagination.configure do |config|
        config.cursor_name = :page
      end
    end
  end

  test "no link for json request with multiple pages on last page with custom cursor name" do
    GearedPagination::Headers.new(page: @many_page_recordset.page(Recording.all.count), controller: @controller_serving_json).apply
    assert @controller_serving_json.headers["Link"].nil?
  end
end
