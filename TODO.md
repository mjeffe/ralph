# TODO List of Items to Implement

This list is for humans! It is a reminder of ideas and tasks that need to be spec'ed

- output is currently overwhelming. I would like something closer to what the VSCode Cline output shows.
- fix logs and combine progress
    - combine metrics into the final message from the loop in the log
    - deal with log accumulation (have a ralph log prune command, or only keep x number over time, etc.
    - find a way to easily tail something that shows iteration # and task being worked on
    - PROGRESS.md should somehow include the iteration #, the associated spec?
    - IMPLEMENTATION_PLAN should also reference the associated spec?
- Change RALPH_VERSION to something else.
    - Or else add semver versioning to ralphs process? but that would affect projects that use it.

