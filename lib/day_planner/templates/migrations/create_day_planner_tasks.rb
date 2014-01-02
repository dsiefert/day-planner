class CreateDayPlannerTasks < ActiveRecord::Migration
	def up
		create_table :day_planner_tasks do |t|
			t.string   :name
			t.integer  :interval
			t.datetime :last_execution
			t.datetime :next_execution
		end
	end

	def down
		drop_table :day_planner_tasks
	end
end
