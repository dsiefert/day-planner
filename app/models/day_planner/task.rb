module DayPlanner
	class Task < ActiveRecord::Base
		self.table_name = :day_planner_tasks

		validate :check_name

		def self.schedule(options)
			unless options[:every]
				raise ArgumentError, "Must specify task interval with :every, other scheduling methods are not yet implemented"
			end

			if options[:every].to_i < DayPlanner.interval.to_i
				raise ArgumentError, "Must specify a task interval at least as long as DayPlanner's check interval."
			end

			fields = {}
			fields[:name] = options.delete(:name) if options[:name]
			fields[:interval] = options.delete(:every).to_i if options[:every]
			fields[:last_execution] = Time.parse("1/1/1")

			task = DayPlanner::Task.create(fields)
		end

		def log(last, now)
			if ActiveRecord::Base.connection.table_exists?('day_planner_log')
				deviation = -(last + interval - now)
				DayPlanner::Log.create(name: name, interval: interval, datetime: now, deviation: deviation)
			end
		end

		def check_name
			if name.present?
				tasks = Task.where(name: name)
				if tasks.count > 1 || (tasks.count == 1 && tasks.first.id != id)
					errors.add(:name, "must be unique if specified")
				end
			end
		end

		def block
			@block
		end

		def block=(block)
			@block = block
		end
	end
end
