class HomeController < ApplicationController
	before_action :authenticate_user!
	ActionController::Parameters.permit_all_parameters = true
	def index
	end

	def save_data
		base_compare = Array.new
		single_stroke = Hash.new
		data_source_hash = Hash.new
		small_x = 21474836
		small_y = 21474836

		# collect first x and y co-ordinates of each stroke separately in base_compare
		# initialize single_stroke[] array for each strokes
		# get normalizing co-ordinates of gesture in small_x and small_y
		params[:finger_data].each do |key, value|
			if !base_compare[value[:id].to_i]
				single_stroke[value[:id].to_i] = Array.new
				base_compare[value[:id].to_i] = {id:value[:id].to_i, x:value[:x].to_i, y:value[:y].to_i}
			end
			if (value[:x].to_i < small_x)
				small_x = value[:x].to_i
			end
			if (value[:y].to_i < small_y)
				small_y = value[:y].to_i
			end
		end

		# get execution order of different strokes in comparision with x and y plain
		order_array = base_compare.sort_by {|h| [ h['x'],h['y'] ]}

		# get execution sequence id, nth execution of gesture
		exec_id = Trajectory.where(:user_id => authenticate_user![:id], :gesture_id => 0 ).pluck(:exec_num)
		if(exec_id[0]==nil)
			exec_id = 1
		else
			exec_id = exec_id[0] + 1
		end

		# collect all points of individual stroke in separate hash single_stroke[value[:id].to_i]
		params[:finger_data].each do |key, value|
			point_data = {
				:x => value[:x].to_i - small_x,
				:y => value[:y].to_i - small_y,
				:time => value[:time].to_i
			}
			single_stroke[value[:id].to_i] << point_data
		end

		# prepare final argument to push into the table
		single_stroke.each do | stroke, data| 
			sequence = order_array.index{|x| x[:id] == stroke}
			puts sequence
			data_source_hash = {
				:user_id => authenticate_user![:id],
				:gesture_id => 0,
				:stroke_id => stroke,
				:exec_num => exec_id,
				:stroke_seq => sequence,
				:points => single_stroke[stroke]
			}
			puts data_source_hash
			puts "--------------------------"
			# trace_detail = Trajectory.new(data_source_hash)
			# trace_detail.save
		end	
	end
end
