Rails.application.routes.draw do
  resources :geolocations, only: [:create]
end
