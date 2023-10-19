require 'active_support/deprecation'

module GearedPagination
  def self.rails_7_1?
    Rails.version >= "7.1.0" rescue false
  end

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new("1.1.2", "GearedPagination")
  end
end

require 'geared_pagination/recordset'
require 'geared_pagination/engine' if defined?(Rails)
