class ChnmmLoginController < ApplicationController
	ActionController::Parameters.permit_all_parameters = true
	def verify_user
		base_compare = Hash.new
		single_stroke = Hash.new
		data_source_hash = Hash.new
		small_x = 21474836
		small_y = 21474836

		# collect first x and y co-ordinates of each stroke separately in base_compare
		# initialize single_stroke[] array for each strokes
		# get normalizing co-ordinates of gesture in small_x and small_y
		params[:finger_data].each do |key, value|
			if !base_compare[value[:color]]
				single_stroke[value[:color]] = Array.new
				base_compare[value[:color]] = {color:value[:color], x:value[:x].to_i, y:value[:y].to_i}
			end
			if (value[:x].to_i < small_x)
				small_x = value[:x].to_i
			end
			if (value[:y].to_i < small_y)
				small_y = value[:y].to_i
			end
		end

		# get execution order of different strokes in comparision with x and y plain
		order_array = base_compare.sort_by {|k,v| v[:x]}

		user_detail = User.where(:email => params[:user_name] ).first
		gesture_ids = Trajectory.where(:user_id => user_detail[:id], :is_password => 1 ).pluck("gesture_id")
		gesture_id = 0
		if(gesture_ids[0]==nil)
			flash[:notice] = 'You have not set any password gesture yet. Please create a password gesture first!'
			redirect_to root_path
		else
			gesture_id = gesture_ids[0]
		end

		# collect all points of individual stroke in separate hash single_stroke[value[:id].to_i]
		params[:finger_data].each do |key, value|
			point_data = Array.new
			point_data[0] = value[:x].to_i - small_x
			point_data[1] = value[:y].to_i - small_y
			point_data[2] = value[:time].to_i
			
			single_stroke[value[:color]] << point_data
		end

		# prepare final argument to push into the table
		# is_password: 0 = normal gesture, 1 = password gesture, 2 = check for password matching
		single_stroke.each do | stroke, data|
			sequence = order_array.find_index { |k,_| k== stroke } 
			data_source_hash = {
				:user_id => user_detail[:id],
				:gesture_id => gesture_id,
				:is_password => 2, 
				:exec_num => 0,
				:stroke_seq => sequence,
				:points => single_stroke[stroke]
			}
			puts data_source_hash
			puts "--------------------------"
			trace_detail = Trajectory.new(data_source_hash)
			trace_detail.save
		end

		# :verified :: 0 = not checked yet, 1 = checked and passed, 2 = checked and failed
		verify_detail = Geslog.new({
				:user_id => user_detail[:id],
				:verified => 0
			})
		verify_detail.save
		flash[:notice] = 'Your gesture is set to queue for verification. Please try Login button for further details!'	
	end

	def login_possible
		user_detail = User.where(:email => params[:user_name] ).first
		login_status = Geslog.where(:user_id => user_detail[:id]).first
		if login_status 
			if login_status[:verified] == 0
				result = 0
				messege = "Gesture verification still in progress!"
			elsif login_status[:verified] ==2
				result = 2
				messege = "Please draw the gesture again and submit, previous gesture failed to verify!"
    			login_status.destroy
    			password_gesture = Trajectory.where(:user_id => user_detail[:id], :is_password => 2 )
    			password_gesture.destroy_all
			else
				messege = user_detail[:pass]
				result = user_detail[:email]
    			login_status.destroy
    			password_gesture = Trajectory.where(:user_id => user_detail[:id], :is_password => 2 )
    			password_gesture.destroy_all
			end
		else
			messege = "Please draw the gesture and press Submit Gesture Data button first!"
			result = 0
		end
		render :json => {:result => result, :messege => messege}
	end
end
