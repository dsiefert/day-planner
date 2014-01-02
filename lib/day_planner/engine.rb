require 'day_planner'
require 'day_planner/generators/day_planner_generator'

module DayPlanner
	class Railtie < Rails::Engine
		isolate_namespace DayPlanner

		unless $0 =~ /rake/ || defined?(::Rails::Console) 
			initializer "day_planner.activate", after: :finisher_hook do
				puts "DayPlanner starting up"
				DayPlanner.clear_tasks
				require Rails.root.join('config', 'scheduled_tasks')
				DayPlanner.activate
			end
		end
	end
end
