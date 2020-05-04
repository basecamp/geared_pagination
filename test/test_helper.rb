ENV['RAILS_ENV'] = 'test'

require_relative './dummy/config/environment'

require 'rails/test_help'
require 'byebug'

class ActiveSupport::TestCase
  private
    def create_recordings(count: 120)
      count.times { |i| Recording.create number: i + 1 }
    end
end
