# TODO List of Items to Implement

This list is for humans! It is a reminder of ideas and tasks that need to be spec'ed

- fix logs and combine progress
    - combine metrics into the final message from the loop in the log
    - deal with log accumulation (have a ralph log prune command, or only keep x number over time, etc.
    - find a way to easily tail something that shows iteration # and task being worked on
    - PROGRESS.md should somehow include the iteration #, the associated spec?
    - IMPLEMENTATION_PLAN should also reference the associated spec?
- Change RALPH_VERSION to something else.
    - Or else add semver versioning to ralphs process? but that would affect projects that use it.
- Add a git branch check to ralph root script. If on main or master, prompt with warning and ask if we want to create a branch

