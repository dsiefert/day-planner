# DayPlanner

Day Planner is a simple tool to manage in-process execution of scheduled tasks in Rails. There are a lot of tools for running scheduled tasks outside the process ([Clockwork](http://rubygems.org/gems/clockwork) is probably what you're looking for if you want an elegant implementation of scheduled tasks outside the main process).

I wrote this because I needed a simple, lightweight tool to schedule small, light tasks on an application running on Heroku, without the extra cost of a dedicated clock process to handle it, but executing more frequently than Heroku's free scheduler permits.

Schedule management is in a thread of its own; scheduled tasks are run in the same thread (I was spawning separate threads for them, but it seemed to be causing issues with database utilization on Heroku). Ruby 2.0's handling of threading is improved over the 1.9 branch, so it may be a good idea to use it, but I obviously can't guarantee that you won't still encounter situations in which poorly behaved tasks block your application's main thread. If you want assurances against that, use any of the other tools (did I mention [Clockwork](http://rubygems.org/gems/clockwork)?)

## Installation

Add this line to your application's Gemfile:

    gem 'day_planner'

And then execute:

    $ bundle install
    $ rails generate day_planner:install
    $ rake db:migrate

## Usage

Installation should have created a file called config/scheduled_tasks.rb. Put tasks in it like this:

    DayPlanner.schedule(every: 2.minutes) do
    	MyClass.my_class_method
    end

This file will be read in and its tasks will be added to the schedule automatically.

The tasks in the schedule will each be performed on startup and then thereafter according to their stated intervals.

I'm not doing a whole damn ton to protect you from tasks that throw errors, but there is a begin/rescue/end up in there at some point. I definitely am not protecting you from a process that just won't end or anything like that. Remember that your interval is more or less the minimum possible time between instances of the task being performed, as it does not spawn a new thread for each task. (That seemed to cause problems with Heroku.) Setting a shorter interval will help, as it will endeavor to catch up to the schedule if it falls behind but will never execute tasks between its check intervals. Setting the check interval too short could end up blocking your application's main thread, though, particularly if your tasks end up running long.

### Options

#### name

You can name a task thusly:

    DayPlanner.schedule(every: 2.minutes, name: "my task") do
        MyClass.my_class_method
    end

If you do, you can find the task later:
    DayPlanner.task("my task")

### Managing DayPlanner and tasks

You can activate or deactivate DayPlanner with those respective methods. You can also check whether it's running with DayPlanner.status.

To cancel a task, call the class method on DayPlanner:

    DayPlanner.cancel(task)

You can either pass a name, if you named the task, or the task object.

Avoid trying to interact with tasks via database calls or ActiveRecord objects. DayPlanner shouldn't attempt to execute any task that isn't scheduled via its methods, as the actual task is retained in memory; the database is only used to track task execution times.

#### DayPlanner.interval

By default, DayPlanner checks for tasks to be performed once per minute. You have the power to change this:

    DayPlanner.interval = 5.seconds

Or, like

    DayPlanner.interval = 5

Since tasks are not run in separate threads (this seemed to be giving me database connection issues on Heroku), remember that the interval is not entirely precise -- if a task takes time to run, keep that in mind (or spin off a new thread yourself in the task). DayPlanner will attempt to run a task before the task's interval has entirely passed in order to get it to execute at its next scheduled time, should the check interval be short enough to manage this, but no guarantees. It will not run the task if less than half of its interval has elapsed since last performance.

Note that if you try to schedule a task with an interval shorter than DayPlanner's interval, it'll complain and fail. If you shorten DayPlanner's interval to less than that of one of its tasks, it'll complain but not fail. The task obviously will only run at scheduler thread's intervals. Use your best judgment.

Specify your preferred interval (and whatever other settings which may be implemented one day) in config/day_planner_tasks.rb. As long as you set your interval before DayPlanner is activated, you won't have to wait for it to cycle through an interval to change the setting. If you alter this value while DayPlanner is already running, it won't take effect until the current interval ends.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
