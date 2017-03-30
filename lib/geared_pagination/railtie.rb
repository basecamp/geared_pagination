require 'rails/railtie'

require 'geared_pagination/helper'
require 'geared_pagination/controller'

class GearedPagination::Engine < ::Rails::Engine
  initializer :webpacker do |app|
    ActiveSupport.on_load :action_controller do
      ActionController::Base.send :include, GearedPagination::Controller
    end
  end
end
