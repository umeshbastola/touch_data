class HomeController < ApplicationController
	ActionController::Parameters.permit_all_parameters = true
	def index
	end

	def save_data
		require 'csv'
		base_compare = Hash.new
		CSV.open("public/csv/finger_data"+Time.now.to_i.to_s+".csv", "w") do |csv|
			csv << ["stroke_id", "x", "y", "time"]
			params[:finger_data].each do |key, value|
				if !base_compare[value[:id]]
					base_compare[value[:id]] = {x:value[:x].to_i, y:value[:y].to_i,time:value[:time].to_i}
				end
				diff_x = base_compare[value[:id]][:x] - value[:x].to_i
				diff_y = base_compare[value[:id]][:y] - value[:y].to_i
				diff_time = value[:time].to_i - base_compare[value[:id]][:time]
				csv << [value[:id], diff_x,diff_y,diff_time]
			end
		end
	end

	def all_csv
		@csv_list =  Dir.entries("public/csv/")
	end
end
