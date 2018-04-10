Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"

	post '/data_post', to: 'home#save_data'
	post '/verify_data_post', to: 'chnmm_login#verify_user'
	post '/login_request', to: 'chnmm_login#login_possible'
end
