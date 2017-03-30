require 'geared_pagination/ratios'
require 'geared_pagination/page'

module GearedPagination
  class Recordset
    attr_reader :records, :ratios

    def initialize(records, per_page: nil)
      @records = records
      @ratios  = GearedPagination::Ratios.new(per_page)
    end

    def page(number)
      GearedPagination::Page.new(number, from: self)
    end

    def page_count
      @page_count ||= begin
        count    = 0
        residual = records_count

        while residual > 0
          count   += 1
          residual = residual - ratios[count]
        end

        count
      end
    end

    def records_count
      @records_count ||= records.unscope(:limit).unscope(:offset).count
    end
  end
end
