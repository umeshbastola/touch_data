Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"

	post '/data_post', to: 'home#save_data'
	get '/csv', to: 'home#all_csv'
end
