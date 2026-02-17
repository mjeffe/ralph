# TODO List of Items to Implement

This list is for humans! It is a reminder of ideas and tasks that need to be spec'ed

- fix logs and combine progress
    - combine metrics into the final message from the loop in the log
    - deal with log accumulation (have a ralph log prune command, or only keep x number over time, etc.
    - find a way to easily tail something that shows iteration # and task being worked on
    - PROGRESS.md is redundant with git logs, so unnecessary
    - PROGRESS.md should somehow include the iteration #, the associated spec?
    - IMPLEMENTATION_PLAN should also reference the associated spec?
- Change RALPH_VERSION to something else.
    - Or else add semver versioning to ralphs process? but that would affect projects that use it.
- Simplify both plan and build prompts


Temp prompt:

study @/specs/ralph-overview.md to understand the system.  Then study @/specs/logging-rework.md . This loggging-rework spec has been partially implemented by ralph. Unfortunately, ralph broke itself and we need to fix it.  The @/.ralph/loop.sh now has a fatal error, which output's:
```
/home/mjeffe/src/mrj/ralph/.ralph/loop.sh: line 323: logging: command not found
```
The reason is that the current IMPLEMENTATION_PLAN.md does not include the spec name.
