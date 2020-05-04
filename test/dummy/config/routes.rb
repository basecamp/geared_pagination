Rails.application.routes.draw do
  resources :recordings do
    get :unpaged, on: :collection
  end
end
