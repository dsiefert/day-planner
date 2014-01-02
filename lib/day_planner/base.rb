require 'day_planner/engine'

module DayPlanner
	@@status = "stopped"
	@@tasks = []

	class << self
		def tasks
			@@tasks
		end

		def task(task)
			if task.is_a?(Integer)
				@@tasks.select{ |t| t.id == task }.first
			elsif task.is_a?(String)
				@@task.select{ |t| t.name == task }.first
			elsif task.is_a?(DayPlanner::Task)
				@@task.select{ |t| t.id == task.id }.first
			end
		end

		def status
			@@status
		end

		def interval
			defined?(@@interval) ? @@interval : 60
		end

		def interval=(value)
			@@interval = value
		end

		def clear_tasks
			@@tasks = []
			ActiveRecord::Base.connection.execute("DELETE FROM #{DayPlanner::Task.table_name}")
		end

		def schedule(options, &block)
			raise ArgumentError, "Failed to pass an options hash" unless options.is_a?(Hash)

			task = DayPlanner::Task.schedule(options)

			if !task.id.nil?
				task.block = block
				@@tasks.push(task)
			else
				raise ArgumentError, "Task creation failed. If you specified a name, was it unique?"
			end

			task
		end

		def cancel(task)
			task = DayPlanner::Task.find_by_name(task) if task.is_a?(String) || task.is_a?(Symbol)
			task = DayPlanner::Task.find(task) if task.is_a?(Integer)

			raise ArgumentError, "DayPlanner couldn't find this task" if task.nil? || !task.is_a?(DayPlanner::Task)

			@@tasks.select!{ |t| t.id != task.id }

			task.destroy
		end

		def deactivate
			@@master.kill if defined?(@@master)
			@@status = "stopped"
			@@tasks = []

			clear_tasks

			true
		end
				
		def activate
			@@master.kill if defined?(@@master)
			@@status = "running"

			if defined?(Rails) && Rails.logger
				Rails.logger.info("DayPlanner activated at #{Time.now.inspect}.")
			else
				puts "DayPlanner activated at #{Time.now.inspect}."
			end

			@@master = Thread.new do
				begin
					while true
						check_schedule
						sleep(interval)
					end
				ensure
					Rails.logger.flush
				end
			end
		end

	private
		def check_schedule
			begin
				DayPlanner.tasks.each_with_index do |t, idx|
					time = Time.now
					task = DayPlanner::Task.find(t.id)

					if task.nil?
						@@tasks.select!{ |item| item.id != t.id }
					else
						if task.last_execution.nil? || (time > task.next_execution && time > task.last_execution + (task.interval / 2))
							task.last_execution = time

							if !task.next_execution.nil?
								task.next_execution += task.interval #move it up by interval, regardless of if it's getting executed late
							else
								task.next_execution = time + task.interval
							end

							task.save!

							t.block.call
						end
					end
				end
			rescue => e
				Rails.logger.error("DayPlanner: task threw error:\n#{e.inspect}")
			end
		end
	end
end