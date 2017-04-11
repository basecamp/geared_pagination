require 'geared_pagination/portion'

module GearedPagination
  class Page
    attr_reader :number, :recordset

    def initialize(number, from:)
      @number, @recordset = number, from
      @portion = GearedPagination::Portion.new(page_number: number, per_page: from.ratios)
    end

    def records
      @records ||= @portion.from(recordset.records)
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
      recordset.page_count == 1
    end

    def last?
      number == recordset.page_count
    end


    def next_number
      number + 1
    end


    def cache_key
      @portion.cache_key
    end
  end
end
