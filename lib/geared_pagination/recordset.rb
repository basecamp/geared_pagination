require 'geared_pagination/order'
require 'geared_pagination/ratios'
require 'geared_pagination/page'
require 'geared_pagination/portions'

module GearedPagination
  class Recordset
    attr_reader :records, :orders, :ratios

    def initialize(records, ordered_by: nil, per_page: nil)
      @records = records
      @orders  = Order.wrap_many(ordered_by)
      @ratios  = Ratios.new(per_page)
    end

    def page(param)
      Page.new portion_for(param), from: self
    end

    def page_count
      @page_count ||= begin
        count    = 0
        residual = records_count

        while residual > 0
          count   += 1
          residual = residual - ratios[count]
        end

        count > 0 ? count : 1
      end
    end

    def records_count
      @records_count ||= records.unscope(:limit).unscope(:offset).unscope(:select).count
    end

    private
      def portion_for(param)
        if orders.none?
          PortionAtOffset.new page_number: page_number_from(param), per_page: ratios
        else
          PortionAtCursor.new cursor: cursor_from(param), ordered_by: orders, per_page: ratios
        end
      end

      def page_number_from(param)
        param.to_i > 0 ? param.to_i : 1
      end

      def cursor_from(param)
        Cursor.from_param(param)
      end
  end
end
