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
			tasks.each do |t|
				Rails.logger.warn("DayPlanner: Check interval exceeds the interval of one of its tasks. The task will perform at most every #{value.inspect}.") if t.interval > value
			end

			@@interval = value
		end

	private
		def check_schedule
			# Rails.logger.debug("DayPlanner is checking for tasks to perform")

			tasks.each do |t|
				if Time.now > t.last_executed + t.interval
					begin
						t.perform
					rescue => e
						Rails.logger.warn("DayPlanner: Scheduled task threw an error! Behave yourselves!")
						Rails.logger.warn(e.inspect)
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
				Rails.logger.warn("DayPlanner: Task caused error on first performance. There's no second chance for a good first impression!")
				Rails.logger.warn(e.inspect)
			end
		end
	end
end

DayPlanner.activate

if defined?(Rails)
	module DayPlanner
		class Railtie < Rails::Railtie
			initializer "Include DayPlanner" do
				ActiveSupport.on_load(:action_controller) do
					include DayPlanner
				end
			end
		end
	end
end