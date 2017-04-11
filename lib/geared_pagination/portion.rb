require 'geared_pagination/ratios'

module GearedPagination
  class Portion
    attr_reader :page_number, :ratios

    def initialize(page_number: 1, per_page: GearedPagination::Ratios.new)
      @page_number, @ratios = page_number, per_page
    end

    def from(scope)
      scope.limit(limit).offset(offset)
    end

    def limit
      ratios[page_number]
    end

    def offset
      (page_number - 1).times.sum { |index| ratios[index + 1] }
    end


    def cache_key
      "#{page_number}:#{ratios.cache_key}"
    end
  end
end
