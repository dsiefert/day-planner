class CreateDayPlannerLog < ActiveRecord::Migration
	def up
		drop_table :day_planner_log

		create_table :day_planner_log do |t|
			t.string   :name
			t.integer  :interval
			t.datetime :datetime
			t.decimal  :deviation, precision: 6
		end
	end

	def down
		drop_table :day_planner_log
	end
end
