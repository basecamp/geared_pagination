require 'geared_pagination/portion'

module GearedPagination
  class Page
    attr_reader :number, :collection

    def initialize(number, from:)
      @number, @collection = number, from
      @portion = GearedPagination::Portion.new(page_number: number, per_page: from.ratios)
    end

    def records
      @records ||= @portion.from(collection.records)
    end


    def used?
      records.load.any?
    end

    def empty?
      records.load.none?
    end


    def first?
      number == 1
    end

    def only?
      collection.page_count == 1
    end

    def last?
      number == collection.page_count
    end


    def next_number
      number + 1
    end
  end
end
