require 'geared_pagination/ratios'
require 'geared_pagination/cursor'
require 'active_support/core_ext/array'

module GearedPagination
  class PortionAtCursor
    attr_reader :cursor, :orders, :ratios
    delegate :page_number, to: :cursor

    def initialize(cursor: Cursor.new, ordered_by:, per_page: Ratios.new)
      @cursor, @orders, @ratios = cursor, ordered_by, per_page
    end

    def from(scope)
      selection_from(scope).order(orderings).limit(limit)
    end

    def next_param(scope)
      Cursor.encode page_number: page_number + 1, values: from(scope).last&.slice(*attributes) || {}
    end


    def cache_key
      "#{page_number}:#{ratios.cache_key}"
    end

    private
      def selection_from(scope)
        Selection.new(scope, orders).from(cursor)
      end

      def orderings
        orders.to_h { |order| [ order.attribute, order.direction ] }
      end

      def limit
        ratios[page_number]
      end

      def attributes
        orders.collect(&:attribute)
      end


      class Selection
        attr_reader :scope, :orders

        def initialize(scope, orders)
          @scope, @orders = scope, orders
        end

        def from(cursor)
          if condition = condition_on(cursor)
            scope.where(condition)
          else
            scope.all
          end
        end

        private
          delegate :table, to: :scope

          def condition_on(cursor)
            if orders.all? { |order| cursor.include?(order.attribute) }
              conditions_on(cursor).reduce { |left, right| table.grouping(left).or(right) }
            end
          end

          def conditions_on(cursor)
            matches.collect { |match| match.condition_on(table, cursor) }
          end

          def matches
            orders.size.downto(1).collect { |i| Match.new(orders[i - 1], orders.take(i - 1)) }
          end
      end

      class Match
        attr_reader :head, :tail

        def initialize(head, tail)
          @head, @tail = head, tail
        end

        def condition_on(table, cursor)
          conditions_on(table, cursor).reduce { |left, right| left.and(right) }
        end

        private
          def conditions_on(table, cursor)
            predicates.collect { |predicate| predicate.condition_on(table, cursor.fetch(predicate.attribute)) }
          end

          def predicates
            tail.collect { |order| Equal.new(order) }.including(Inequal.new(head))
          end
      end

      class Predicate
        attr_reader :order
        delegate :attribute, to: :order

        def initialize(order)
          @order = order
        end

        def condition_on(table, value)
          raise NotImplementedError
        end
      end

      class Equal < Predicate
        def condition_on(table, value)
          table[attribute].eq(value)
        end
      end

      class Inequal < Predicate
        def condition_on(table, value)
          if order.asc?
            table[attribute].gt(value)
          else
            table[attribute].lt(value)
          end
        end
      end
  end
end
