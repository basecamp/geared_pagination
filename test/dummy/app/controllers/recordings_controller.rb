class RecordingsController < ActionController::Base
  def index
    set_page_and_extract_portion_from Recording.all, per_page: params[:per_page]
    render json: @page.records if stale? etag: "placeholder"
  end

  def unpaged
    @page = "not a geared pagination page"
    head :ok if stale? etag: "placeholder"
  end
end
