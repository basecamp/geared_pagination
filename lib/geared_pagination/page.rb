module GearedPagination
  class Page
    attr_reader :recordset

    def initialize(portion, from:)
      @portion, @recordset = portion, from
    end

    def number
      @portion.page_number
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


    def next_param
      @portion.next_param recordset.records
    end


    def cache_key
      "page/#{@portion.cache_key}"
    end
  end
end
