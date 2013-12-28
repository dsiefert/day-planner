module DayPlanner
	@@tasks = []

	class << self
		def tasks
			@@tasks
		end

		def schedule(options, &block)
			raise ArgumentError unless options.is_a?(Hash)

			Task.new(options, &block)
		end

		def activate
			@@master.kill if defined?(@@master)

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

	private
		def check_schedule
			tasks.each do |t|
				if Time.now > t.last_executed + t.interval
					begin
						t.perform
					rescue => e
						puts "DayPlanner: Scheduled task threw an error! Behave yourselves!"
						puts e.inspect
					end
				end
			end
		end
	end

	class Task
		attr_reader :last_executed, :interval

		def perform
			@last_executed = Time.now

			@thread.kill if defined?(@thread)

			@thread = Thread.new do
				@task.call
			end
		end

		def initialize(options, &block)
			if options[:every]
				@interval = options[:every]
				raise ArgumentError, "DayPlanner: Task interval is less than scheduler interval. Task not scheduled." if @interval < DayPlanner.interval
			else
				raise ArgumentError, "DayPlanner: Scheduling tasks at anything other than simple intervals using 'every' is still not implemented, not even a little bit."
			end

			@task = block

			DayPlanner.tasks.push(self)

			begin
				perform
			rescue => e
				puts "DayPlanner: Task caused error on first performance. There's no second chance for a good first impression!"
				puts e.inspect
			end
		end
	end
end

DayPlanner.activate

require File.expand_path('config/day_planner_tasks') if defined?(Rails)
