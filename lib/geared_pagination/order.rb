module GearedPagination
  class Order
    INVALID_DIRECTION = "Invalid direction for order on %p: expected :asc or :desc, got %p"

    attr_reader :attribute, :direction

    class << self
      def wrap_many(objects)
        Array.wrap(objects).flat_map { |object| wrap object }
      end

      def wrap(object)
        case object
        when Symbol
          new attribute: object
        when Hash
          object.collect { |key, value| new attribute: key, direction: value }
        when self
          object
        else
          raise ArgumentError, "Invalid orders: expected Symbol, Hash, or GearedPagination::Order, got #{object.inspect}"
        end
      end
    end

    def initialize(attribute:, direction: :asc)
      @attribute = attribute.to_sym
      @direction = direction.presence_in(%i[ asc desc ]) ||
        raise(ArgumentError, INVALID_DIRECTION % [ attribute, direction ])
    end

    def asc?
      direction == :asc
    end

    def desc?
      !asc?
    end

    def ==(other)
      other.is_a?(Order) && attribute == other.attribute && direction == other.direction
    end
  end
end
