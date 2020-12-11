require 'geared_pagination/ratios'

module GearedPagination
  class PortionAtOffset
    attr_reader :page_number, :ratios

    def initialize(page_number: 1, per_page: Ratios.new)
      @page_number, @ratios = page_number, per_page
    end

    def from(scope)
      scope.limit(limit).offset(offset)
    end

    def limit
      ratios[page_number]
    end

    def offset
      variable = [(page_number - 1), ratios.size - 1].min.times.sum { |index| ratios[index + 1] }
      fixed = [page_number - ratios.size, 0].max * ratios.fixed

      variable + fixed
    end

    def next_param(*)
      page_number + 1
    end


    def cache_key
      "#{page_number}:#{ratios.cache_key}"
    end
  end
end
