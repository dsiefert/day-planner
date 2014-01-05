class CreateDayPlannerLog < ActiveRecord::Migration
	def up
		create_table :day_planner_log do |t|
			t.string   :name
			t.integer  :interval
			t.datetime :datetime
		end
	end

	def down
		drop_table :day_planner_log
	end
end
