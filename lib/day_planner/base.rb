module DayPlanner
	@@tasks = []
	@@named_tasks = {}
	@@status = "stopped"

	class Railtie < Rails::Railtie
		config.after_initialize do
			require File.expand_path('config/scheduled_tasks')
			DayPlanner.activate
		end
	end

	class << self
		def tasks
			@@tasks
		end

		def schedule(options, &block)
			raise ArgumentError unless options.is_a?(Hash)

			Task.new(options, &block)
		end

		def cancel(task)
			task = find_task(task) if task.is_a?(String)
			raise ArgumentError, "DayPlanner couldn't find this task" if task.nil? || !task.is_a?(DayPlanner::Task)
			task.destroy
		end

		def status
			@@status
		end

		def deactivate
			@@master.kill if defined?(@@master)
			@@status = "stopped"
		end
				
		def activate
			@@master.kill if defined?(@@master)
			@@status = "running"

			if defined?(Rails) && Rails.logger
				Rails.logger.info("DayPlanner activated.")
			else
				puts "DayPlanner activated."
			end

			@@master = Thread.new do
				while true
					check_schedule
					sleep(interval)
				end
			end
		end

		def interval
			defined?(@@interval) ? @@interval : 60
		end

		def interval=(value)
			@@interval = value
		end

		def find_task(name)
			@@named_tasks[name]
		end

		def register_task_name(name, task)
			raise ArgumentError unless task.is_a?(DayPlanner::Task)
			raise ArgumentError unless @@named_tasks[name].nil?
			@@named_tasks[name] = task
		end

		def delete_task_name(name)
			@@named_tasks.delete(name)
		end

	private
		def check_schedule
			tasks.each do |t|
				if Time.now > t.last_executed + t.interval
					begin
						t.perform
					rescue => e
						if defined?(Rails) && Rails.logger
							Rails.logger.error("DayPlanner: Scheduled task threw an error! Behave yourselves!\n#{e.inspect}")
						else
							puts "DayPlanner: Scheduled task threw an error! Behave yourselves!\n#{e.inspect}"
						end
					end
				end
			end
		end
	end

	class Task
		attr_reader :last_executed, :interval

		def perform
			if @environment.nil? || (defined?(Rails) && defined?(Rails.env) && Rails.env == @environment)
				@last_executed = Time.now

				@task.call
			else
				log_info = "DayPlanner: "

				if @name
					log_info += "Skipping task '#{@name}'"
				else
					log_info += "Skipping a task"
				end

				log_info += " because it's set for environment '#{@environment}'."

				if defined?(Rails) && Rails.logger
					Rails.logger.info(log_info)
				else
					puts log_info
				end
			end
		end

		def destroy
			DayPlanner.tasks.delete(self)
			if @name
				DayPlanner.delete_task_name(@name)
			end
		end

		def initialize(options, &block)
			if options[:every]
				@interval = options[:every]
				raise ArgumentError, "DayPlanner: Task interval is less than scheduler interval. Task not scheduled." if @interval < DayPlanner.interval
			else
				raise ArgumentError, "DayPlanner: Scheduling tasks at anything other than simple intervals using 'every' is still not implemented, not even a little bit."
			end

			if options[:name]
				name = options.delete(:name)
				if !DayPlanner.find_task(name)
					@name = name
					DayPlanner.register_task_name(name, self)
				end
			end

			@environment = options.delete(:environment) if options[:environment]

			@task = block

			DayPlanner.tasks.push(self)
			log_info = "DayPlanner: New task added"
			log_info += ": '#{@name}'" unless @name.nil?
			log_info += " with an execution interval of #{@interval.to_i} seconds."

			if defined?(Rails) && Rails.logger
				Rails.logger.info(log_info)
			else
				puts log_info
			end

			begin
				perform
			rescue => e
				if defined?(Rails) && Rails.logger
					Rails.logger.error("DayPlanner: Task caused error on first performance. There's no second chance for a good first impression!\n#{e.inspect}")
				else
					puts "DayPlanner: Task caused error on first performance. There's no second chance for a good first impression!\n#{e.inspect}"
				end
			end
		end
	end
end
