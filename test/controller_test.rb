require 'test_helper'
require 'geared_pagination'
require 'geared_pagination/controller'
require 'active_support/all'
require 'action_controller'

class RecordingsController < ActionController::Base
  include GearedPagination::Controller

  def index
    set_page_and_extract_portion_from Recording.all, per_page: params[:per_page]
    render json: @page.records if stale? etag: "placeholder"
  end

  def unpaged
    @page = "not a geared pagination page"
    head :ok if stale? etag: "placeholder"
  end
end

class GearedPagination::ControllerTest < ActionController::TestCase
  tests RecordingsController

  setup do
    @routes = ActionDispatch::Routing::RouteSet.new.tap do |r|
      r.draw do
        resources :recordings do
          get :unpaged, on: :collection
        end
      end
    end
  end

  test "ETag includes the current page and gearing" do
    get :index, params: { per_page: [ 1, 2 ] }
    assert_equal etag_for("placeholder", "page/1:1-2"), response.etag
    etag_before_gearing_change = response.etag

    get :index, params: { page: 1, per_page: [ 1, 2 ] }
    assert_equal etag_before_gearing_change, response.etag

    get :index, params: { page: 1, per_page: [ 1, 3 ] }
    assert_not_equal etag_before_gearing_change, response.etag
  end

  test "ETag is ignored when @page is not a geared page" do
    get :unpaged
    assert_equal etag_for("placeholder"), response.etag
  end

  test "Link headers on JSON requests" do
    get :index, format: 'json'
    assert_equal "120", response.headers["X-Total-Count"]
    assert_equal '<http://test.host/recordings.json?page=2>; rel="next"', response.headers["Link"]
  end

  test "no Link headers on non-JSON requests" do
    get :index
    assert_nil response.headers["Link"]
  end

  private
    def etag_for(*keys)
      %(W/"#{Digest::MD5.hexdigest(ActiveSupport::Cache.expand_cache_key(keys))}")
    end
end
