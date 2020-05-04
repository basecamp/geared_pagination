require 'rails/engine'
require 'geared_pagination/controller'

class GearedPagination::Engine < ::Rails::Engine
  initializer :geared_pagination do |app|
    ActiveSupport.on_load :action_controller do
      ActionController::Base.send :include, GearedPagination::Controller
    end
  end
end
