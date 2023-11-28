require 'active_support/deprecation'
require_relative "geared_pagination/version"

module GearedPagination
  def self.rails_7_1?
    Rails.version >= "7.1.0" rescue false
  end

  def self.deprecator
    @deprecator ||= ActiveSupport::Deprecation.new(VERSION, "GearedPagination")
  end
end

require 'geared_pagination/recordset'
require 'geared_pagination/engine' if defined?(Rails)
