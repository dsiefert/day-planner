# DayPlanner

Day Planner is a simple tool to manage in-process execution of scheduled tasks. There are a lot of tools for running scheduled tasks outside the process ([Clockwork](http://rubygems.org/gems/clockwork) is probably what you're looking for if you want an elegant implementation of scheduled tasks outside the main process).

I wrote this because I needed a simple, lightweight tool to schedule small, light tasks on an application running on Heroku, without the extra cost of a dedicated clock process to handle it, but executing more frequently than Heroku's free scheduler permits.

Schedule management is in a thread of its own; each scheduled task is run in a thread as well, meaning that lots of long-running tasks could result in lots of threads. Ruby 2.0's handling of threading is improved over the 1.9 branch, so I require that as a minimum, but I obviously can't guarantee that you won't encounter situations in which poorly behaved tasks block your application's main thread. If you want assurances against that, use any of the other tools (did I mention [Clockwork](http://rubygems.org/gems/clockwork)?)

## Installation

Add this line to your application's Gemfile:

    gem 'day_planner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install day_planner

If you're using Rails, it'll expect to find a file listing scheduled tasks in 'config/scheduled_tasks.rb'. If you're not using Rails, do whatever makes you happy. Stick some scheduled tasks somewhere and make sure it's somewhere that runs when your application starts.

## Usage

### Rails

Create a file called config/scheduled_tasks.rb. Put tasks in it like this:

    DayPlanner.schedule(every: 2.minutes) do
    	MyClass.my_class_method
    end

This file will be read in and its tasks will be added to the schedule automatically.

### If you're not using Rails

I don't really know if it'll work. I haven't tried.

You will have to create a scheduled tasks file, somewhere. Use the same format, but obviously you won't have those cute little Rails-y time methods. You'll want to include this at the bottom:

    DayPlanner.activate

It's only activated automatically in Rails.

I have not tested it outside of Rails and it may not work at all but ideally I'd prefer that it did. If you can give me feedback, I'd be much obliged.

### Either way

The tasks in the schedule will each be performed on startup and then thereafter according to their stated intervals.

I'm not doing a whole damn ton to protect you from tasks that throw errors, but there is a begin/rescue/end up in there at some point. I definitely am not protecting you from a process that just won't end or anything like that. Remember that your interval is really the minimum possible time between instances of the task being performed, as it does not spawn a new thread for that purpose.

By default, DayPlanner checks for tasks to be performed once per minute. You have the power to change this:

    DayPlanner.interval = 5.seconds

Or, like

    DayPlanner.interval = 5

Note that if you try to schedule a task with an interval shorter than DayPlanner's interval, it'll complain and fail. If you shorten DayPlanner's interval to less than that of one of its tasks, it'll complain but not fail. The task obviously will only run at scheduler thread's intervals. Use your best judgment.

Specify your preferred interval (and whatever other goodies may be waiting in the pipeline) in config/day_planner_tasks.rb. Note that you probably won't manage to precede that first minute-long wait. I may default to a shorter value in the future. I dunno. Don't pressure me.

### Other options

#### name

You can name a task thusly:

    DayPlanner.schedule(every: 2.minutes, name: "my task") do
        MyClass.my_class_method
    end

If you do, you can find the task later:
    DayPlanner.find_task("my task")

#### environment

If you're using Rails, you can include environment in your options hash, setting the value to the Rails environment in which you'd like the task executed. For example:

    DayPlanner.schedule(every: 1.hour, name: "occasional task", environment: "production") do
        # I run every hour, but only if you're using Rails and in production.
    end

To cancel a task, you can either call the task's "destroy" method, or call a class method on DayPlanner:
    DayPlanner.cancel(task)

You can either pass a name, if you named the task, or the task object.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
