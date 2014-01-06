class CreateDayPlannerLog < ActiveRecord::Migration
	def up
		create_table :day_planner_log do |t|
			t.string   :name
			t.integer  :interval
			t.datetime :datetime
			t.decimal  :deviation, precision: 15, scale: 6
			t.decimal  :cumulative_deviation, precision: 15, scale: 6
		end
	end

	def down
		drop_table :day_planner_log
	end
end
