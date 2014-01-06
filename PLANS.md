## For future releases ##

### Track tasks across application launch instances ###
This is basically a gimme as long as we're already recording stuff in a database:
* Delete only anonymous tasks on initialize, don't delete anything with a persistent name and interval
	* But do delete any task with an unfamiliar name or name, interval combo
* Don't worry about task content changing. Fine, change it. We don't store that in a database anyway.
* Do delete any unfamiliar tasks (i.e. anything in day_planner_tasks that isn't listed in our schedule file)
* Don't reinitialize persistent events, just keep them on schedule. This helps especially if e.g. dealing with a pricy API -- why pull more often than needed?

### Attempt some degree of control with multi-process instances ###
Not sure exactly how to do this.
* Store a record of the scheduler's execution status in a database? Then use that to avoid it being unnecessarily run in multiple threads?
* Whichever process hits first grabs it. For Heroku compatibility, though, I don't think we can rely on that over long periods.
	* How about if other processes monitor for it at the long_heartbeat? Need to find way to determine if anyone's checking, though. I'm not sure how Heroku's dyno-restarting stuff works, but I don't know that we get an alarm when a vital dyno is going down.
* Hell, even an optional "view scheduler status" page in the app. Why not?

### Some degree of DB independence ###
This needs to wait until we have the multi-process thing down.
* Set a separate interval for updating the DB, and in between just use in-memory stuff? Call it the long_heartbeat.
	* This probably would need to be done on some sort of basis of strict multiples, i.e. every 6th tick, update the database. Make sure that we can be okay with circumstances in which the DB is not up to date. (Tasks might resume unnecessarily soon, etc., but shit, do I care?)
* The value of this is when the interval is quite low, at which point both the DB usage and the time that the queries take starts dominating the scene

### Other task scheduling techniques ###
Something cronesque, but not so annoying. Maybe options like hourly, daily, weekly, accompanied (optionally) by at, or on. These would need different logic from our "every", try-to-stay-on-task style items.
