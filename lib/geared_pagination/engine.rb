require 'singleton'
require 'rails/engine'
require 'geared_pagination/controller'

module GearedPagination
  class << self
    def configure
      yield config
    end

    def config
      @_config ||= Configuration.new
    end
  end

  class Configuration
    include ActiveSupport::Configurable
    config_accessor :cursor_name, default: :page
  end

  class Engine < ::Rails::Engine
    initializer :geared_pagination do |app|
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send :include, GearedPagination::Controller
      end
    end
  end

  if GearedPagination.rails_7_1?
    initializer "geared_pagination.deprecator" do |app|
      app.deprecators[:geared_pagination] = GearedPagination.deprecator
    end
  end
end
