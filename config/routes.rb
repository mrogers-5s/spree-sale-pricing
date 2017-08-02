Spree::Core::Engine.routes.draw do
  namespace :admin do

    resources :products, only: [] do
      resources :sale_prices do
        member do
          put :disable
          put :enable
        end
      end
    end

  end
end
