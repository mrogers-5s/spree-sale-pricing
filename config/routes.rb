Spree::Core::Engine.routes.draw do
  namespace :admin do

    post '/spree_sales/import', to: "sale_prices#import", as: :spree_sales_import

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