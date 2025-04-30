require 'rails/engine'
require 'geared_pagination/controller'

class GearedPagination::Engine < ::Rails::Engine
  initializer :geared_pagination do |app|
    ActiveSupport.on_load :action_controller do
      ActionController::Base.send :include, GearedPagination::Controller
    end
  end

  if GearedPagination.rails_7_1?
    initializer "geared_pagination.deprecator" do |app|
      app.deprecators[:geared_pagination] = GearedPagination.deprecator
    end
  end
end
