require 'addressable/uri'

module GearedPagination
  class Headers
    def initialize(page:, controller:)
      @page, @controller = page, controller
    end

    def apply
      @controller.headers.update(headers) if applicable?
    end

    private
      def headers
        Hash.new.tap do |h|
          h["X-Total-Count"] = @page.collection.records_count.to_s
          h["Link"] = next_page_link_header unless @page.last?
        end
      end

      def applicable?
        @controller.request.format&.json?
      end

      def next_page_link_header
        link_header(rel: :next, page_number: @page.next_number).to_s
      end

      def link_header(rel:, page_number:)
        uri = Addressable::URI.parse(@controller.request.url)
        uri.query_values = (uri.query_values || {}).merge("page" => page_number)
        %{<#{uri}>; rel="#{rel}"}
      end
  end
end
