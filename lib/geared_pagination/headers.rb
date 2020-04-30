require 'addressable/uri'

module GearedPagination
  class Headers
    def initialize(page:, controller:)
      @page, @controller = page, controller
    end

    def apply
      controller.headers.update(headers) if applicable?
    end

    private
      attr_reader :page, :controller
      delegate :request, to: :controller

      def headers
        Hash.new.tap do |h|
          h["X-Total-Count"] = page.recordset.records_count.to_s
          h["Link"] = next_page_link_header unless page.last?
        end
      end

      def applicable?
        request.format&.json?
      end

      def next_page_link_header
        link_header(rel: :next, page: page.next_param).to_s
      end

      def link_header(rel:, page:)
        %{<#{uri(page: page)}>; rel="#{rel}"}
      end

      def uri(page:)
        Addressable::URI.parse(request.url).tap do |uri|
          uri.query_values = (uri.query_values || {}).merge("page" => page)
        end.to_s
      end
  end
end
