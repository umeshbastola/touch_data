class HomeController < ApplicationController
	before_action :authenticate_user!
	ActionController::Parameters.permit_all_parameters = true
	def index
		@users = User.all
		@gestures = Tgesture.all
		@me = authenticate_user![:email]
	end

	def save_data
		base_compare = Hash.new
		single_stroke = Hash.new
		data_source_hash = Hash.new
		small_x = 21474836
		small_y = 21474836
		final_msg = ""

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

		# get execution sequence id, nth execution of gesture
		exec_id = Trajectory.where(:user_id => authenticate_user![:id], :gesture_id => params[:gesture_id] ).maximum("exec_num")
		if(exec_id==nil)
			exec_id = 1
			first = true
		else
			raw_data = Trajectory.where(:user_id => authenticate_user![:id], :gesture_id => params[:gesture_id], :exec_num => 1 )
			exec_id = exec_id + 1
			first = false
		end

		# collect all points of individual stroke in separate hash single_stroke[value[:id].to_i]
		params[:finger_data].each do |key, value|
			point_data = Array.new
			point_data[0] = value[:x].to_i - small_x
			point_data[1] = value[:y].to_i - small_y
			point_data[2] = value[:time].to_i
			
			single_stroke[value[:color]] << point_data
		end
		if single_stroke.length != params[:num_stroke].to_i
			final_msg += "This gesture requires exactly "+params[:num_stroke] +" strokes, the number of finger strokes does not match!\n"
			render :json => {:result => final_msg}
			return
		end
		if (!first && params[:password_gesture]==0)
			all_distances = Array.new
			single_stroke.each do | stroke, data|
				all_distances.push(shortest_distance(single_stroke[stroke][0],raw_data))
			end
			all_distances.each do | serial | 
				for k in 0..(all_distances.length-1)				
			  		if serial.keys[0] == all_distances[k].keys[0]
			  			if serial.values[0] > all_distances[k].values[0]
			  				rem = serial.keys[0]
			  				serial.delete(rem)
			  			elsif serial.values[0] < all_distances[k].values[0]
			  				rem = all_distances[k].keys[0]
			  				all_distances[k].delete(rem)
			  			end
			  		end
				end
			end
			unique_key = Array.new
			error_sum = 0
			for k in 0..(all_distances.length-1)
				error_sum += all_distances[k].values[0]
				unique_key.push(all_distances[k].keys[0])
			end
	  		if error_sum.to_i > params[:num_stroke].to_i*100 || unique_key.length != unique_key.uniq.length
	  			final_msg += "Your gesture does not match with previous execution of the gesture selected, please try again!"
	  			render :json => {:result => final_msg}
	  			return
	  		end
		end
		# prepare final argument to push into the table
		# is_password: 0 = normal gesture, 1 = password gesture, 2 = check for password matching
		i=0
		single_stroke.each do | stroke, data|
			if(params[:gesture_id].to_i < 3 && !first && params[:password_gesture]==0)
				sequence = all_distances[i].keys[0]
			else
				sequence = order_array.find_index { |k,_| k== stroke } 
			end		
			data_source_hash = {
				:user_id => authenticate_user![:id],
				:gesture_id => params[:gesture_id],
				:is_password => params[:password_gesture],
				:exec_num => exec_id,
				:stroke_seq => sequence,
				:points => single_stroke[stroke]
			}
			i += 1
			puts data_source_hash
			# puts "--------------------------"
			trace_detail = Trajectory.new(data_source_hash)
			trace_detail.save
		end	
		render :json => {:result => "Gesture sucessfully uploaded!"}
		return
	end

	def get_gesture
		strokes = Array.new
		raw_data = Trajectory.where(:user_id => params[:id], :gesture_id => params[:gesture_id] )
		raw_data.each do | stroke | 
			if strokes[stroke[:stroke_seq]]
				strokes[stroke[:stroke_seq]].push(stroke[:points])
			else
				first_stroke = Array.new
				first_stroke.push(stroke[:points])
				strokes[stroke[:stroke_seq]] = first_stroke
			end
		end
		render :json => {:result => raw_data}
	end

	def get_single_exec
		raw_data = "a"
		exec_id = Trajectory.where(:user_id => params[:id], :gesture_id => params[:gesture_id] ).maximum("exec_num")
		if(exec_id != nil)
			raw_data = Trajectory.where(:user_id => params[:id], :gesture_id => params[:gesture_id], :exec_num => exec_id )
		end
		render :json => {:result => raw_data, :last_exec => exec_id}
	end

	def shortest_distance(pt,raw_data)
		distance = Hash.new
		raw_data.each do | str |
	  		distance[str[:stroke_seq]] = euclidean_distance([pt[0],pt[1]],[str[:points][0][0].to_i,str[:points][0][1].to_i])
	  	end
	  	distance = Hash[distance.sort_by{|k, v| v}]
	  return distance
	end


	def euclidean_distance(p1,p2)
	  sum_of_squares = 0
	  p1.each_with_index do |p1_coord,index| 
	    sum_of_squares += (p1_coord - p2[index]) ** 2 
	  end
	  return Math.sqrt( sum_of_squares )
	end

	def destroy
		Trajectory.where(:user_id => authenticate_user![:id], :gesture_id => params[:gesture_id] ).destroy_all
	end

	def destroy_last
		exec_id = Trajectory.where(:user_id => authenticate_user![:id], :gesture_id => params[:gesture_id] ).maximum("exec_num")
		puts exec_id
		if exec_id != nil 	
			Trajectory.where(:user_id => authenticate_user![:id], :gesture_id => params[:gesture_id], :exec_num => exec_id ).destroy_all
		end
	end

	def dollarn
		
	end

	def get_gestures
		gestures = Trajectory.order(:user_id,:gesture_id,:exec_num)
		# all_trajectories = Array.new
		# gestures.each do |trajectory |
		# 	points = Hash.new
		# 	trajectory.points.each_with_index do | val, index |
		# 		points[index] = val
		# 	end
		# 	path = Interpolate::Points.new(points)
		# 	interpolated_points = Array.new
		# 	(0).step(points.length, (points.length/10.0).round) do |time|
		# 	  position = path.at(time)
		# 	  interpolated_points.push(position)
		# 	end
		# 	puts interpolated_points.length
		# 	data_source_hash = {
		# 		:user_id => trajectory.user_id,
		# 		:gesture_id => trajectory.gesture_id,
		# 		:exec_num => trajectory.exec_num,
		# 		:points => interpolated_points
		# 	}
		# 	all_trajectories.push(data_source_hash)
		# end
		render :json => {:result => gestures}
	end
end
