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

If you're using Rails, it'll expect to find a file listing scheduled tasks in 'config/day_planner_tasks.rb'. If you're not using Rails, do whatever makes you happy. Stick some scheduled tasks somewhere and make sure it's somewhere that runs when your application starts.

## Usage

Here's an example of a scheduled task, living in (app)/config/scheduled_tasks.rb (this is the required/automatic location of the schedule file if you're using Rails):

    DayPlanner.schedule(every: 2.minutes) do
    	MyClass.my_class_method
    end

Obviously you only get those cute little time methods in Rails; otherwise, pass in an integer number of seconds. More sophisticated ways of scheduling tasks are intended in the future, but for now you'll just have to cope. If you don't specify an interval with 'every', it'll happen once and never again.

The tasks in the schedule will each be performed on startup and then thereafter according to their stated intervals.

I'm not doing a whole damn ton to protect you from tasks that throw errors, but there is a begin/rescue/end up in there at some point. I definitely am not protecting you from a process that just won't end or anything like that. Given that each task is run in its own thread, you have some faint assurance that they are occuring at whatever interval you specify plus a very small amount of overhead.

By default, DayPlanner checks for tasks to be performed once per minute. You have the power to change this:

    DayPlanner.interval = 5.seconds

Or, like

    DayPlanner.interval = 5

Note that if you try to schedule a task with an interval shorter than DayPlanner's interval, it'll complain and fail. If you shorten DayPlanner's interval to less than that of one of its tasks, it'll complain but not fail. It obviously will only run at scheduler thread's intervals. Use your best judgment.

Specify your preferred interval (and whatever other goodies may be waiting in the pipeline) in config/day_planner_tasks.rb. Note that you probably won't manage to precede that first minute-long wait. I may default to a shorter value in the future. I dunno. Don't pressure me.

### Non-Rails uses

I sort of think it might work without Rails, keeping in mind the various aforementioned caveats? I'm not really sure. If it totally doesn't, I'd appreciate feedback.

You can name a task thusly:
    DayPlanner.schedule(every: 2.minutes, name: "my task") do
    	MyClass.my_class_method
    end

If you do, you can find the task later:
    DayPlanner.find_task("my task")

To cancel a task, you can either call the task's "destroy" method, or call a class method on DayPlanner:
    DayPlanner.cancel(task)

You can either pass a name, if you named the task, or the task object.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
