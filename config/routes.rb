Rails.application.routes.draw do
  resources :geolocations, only: %i[create] do
    collection do
      delete :destroy
    end
  end
end
