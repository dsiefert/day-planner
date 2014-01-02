require 'rails'
require 'rails/generators'

module DayPlanner
	module Generators
		class InstallGenerator < ::Rails::Generators::Base
			include ::Rails::Generators::Migration

			source_root File.expand_path('../../templates', __FILE__)

			def copy_migrations
				copy_migration "create_day_planner_tasks"
			end

			def create_schedule_file
				create_file "config/scheduled_tasks.rb", <<-EOS.gsub(/^\w+/, '')
# Example tasks:
#
# DayPlanner.schedule(every: 1.minute, name: "My Task") do
#   MyClass.my_task
# End
				EOS
			end

		protected

			def copy_migration(filename)
				if self.class.migration_exists?("db/migrate", filename)
					say_status("skipped", "Migration #{filename} already exists")
				else
					migration_template("migrations/#{filename}.rb", "db/migrate/#{filename}.rb")
				end
			end

			def self.next_migration_number(path)
				unless @previous_migration_number
					@previous_migration_number = Time.now.utc.strftime('%Y%m%d%H%M%S').to_i
				else
					@previous_migration_number += 1
				end
				@previous_migration_number.to_s
			end
		end
	end
end