require 'active_support/core_ext/module/deprecation'

module GearedPagination
  class Page
    attr_reader :recordset

    def initialize(portion, from:, deferred_join: false)
      @portion, @recordset, @deferred_join = portion, from, deferred_join
    end

    def number
      @portion.page_number
    end

    def records
      @records ||= begin
        records = @portion.from(recordset.records)
        deferred_join? ? with_deferred_join(records) : records
      end
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

    def before_last?
      number < recordset.page_count
    end


    def next_param
      @portion.next_param recordset.records
    end

    alias_method :next_number, :next_param
    deprecate next_number: "use #next_param instead"


    def cache_key
      "page/#{@portion.cache_key}"
    end

    def deferred_join?
      @deferred_join
    end

    private
      # inspired by the fast_page gem
      def with_deferred_join(relation)
        limited_ids = relation.except(:includes).pluck(relation.primary_key)

        if limited_ids.empty?
          relation.none
        else
          relation.where(relation.primary_key => limited_ids)
        end
      end
  end
end
