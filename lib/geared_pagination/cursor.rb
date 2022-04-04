require 'base64'
require 'active_support/json'

module GearedPagination
  class Cursor
    class << self
      def from_param(key)
        key.present? ? decode(key) : new
      rescue ArgumentError, JSON::ParserError
        new
      end

      def decode(key)
        if attributes = ActiveSupport::JSON.decode(Base64.urlsafe_decode64(key))
          new **attributes.deep_symbolize_keys
        end
      end

      def encode(page_number: 1, values: {})
        Base64.urlsafe_encode64 ActiveSupport::JSON.encode(page_number: page_number, values: values)
      end
    end

    attr_reader :values

    def initialize(page_number: 1, values: {})
      @page_number, @values = page_number, values
    end

    def page_number
      @page_number > 0 ? @page_number : 1
    end

    def fetch(attribute)
      values.fetch(attribute)
    end

    def include?(attribute)
      values.include?(attribute)
    end
  end
end
