module GearedPagination
  class Ratios
    DEFAULTS = [ 15, 30, 50, 100 ]

    def initialize(ratios = nil)
      @ratios = Array(ratios || DEFAULTS).map(&:to_i)
    end

    def [](page_number)
      @ratios[page_number - 1] || fixed
    end

    def cache_key
      @ratios.join('-')
    end

    def size
      @ratios.size
    end

    def fixed
      @ratios.last
    end
  end
end
