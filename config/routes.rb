Rails.application.routes.draw do
  resources :geolocations, only: %i[create] do
    collection do
      delete :destroy
      get :provide
    end
  end
end
