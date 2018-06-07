Rails.application.routes.draw do
  devise_for :users, :controllers => { registrations: 'registrations' }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"

	post '/data_post', to: 'home#save_data'
	post '/verify_data_post', to: 'chnmm_login#verify_user'
	post '/login_request', to: 'chnmm_login#login_possible'
	get '/get_gesture/:id/:gesture_id', to: 'home#get_gesture'
	get '/get_last/:id/:gesture_id', to: 'home#get_single_exec'
	get 'delete_gesture', :to => 'home#destroy'
	get 'delete_gesture_exec', :to => 'home#destroy_last'
	get 'dollarn', :to => 'home#dollarn'
	get 'all_gestures', :to => 'home#get_gestures'
	get 'reference', :to => 'chnmm_login#reference'
end
