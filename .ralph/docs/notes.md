# Notes

Notes from The original [Ralph post](https://ghuntley.com/ralph/)

## Files

**specs/README.md**:

The overall context for the project's *current functionality*.
This is the PIN, the frame of reference for what this project is all about.
Continually evolves as the project grows.
Contains a bunch of lookup tables that give hints to the search tool such as what are the words used for a given featuer, referencing specs, code, etc.
It should contain whatever it needs to increse the search tool's hit rate ???
The more it can use this context, the less it will invent.


## PLAN PHASE

start session

prompt>

    study specs/README.md

prompt>

    I want to add product analytics like posthog into loom. it would be
    used by products built on loom thus we are collecting information about
    non-authenticated users.  Let's have a discussion and you can interview me.


Once you are happy, have it write out the implementation plan.

prompt>

    ok, update specs/*.md and create implementation plan for posthog and add
    bullet points and cite the specification for lookup source or source code 
    that needs to be adjusted.

It then created:

- Create specs/analytics-system.md specification
- Update specs/README.md with new analytics spec entry
- Create specs/analytics-system-implementation-plan.md with bullet points


## BUILD PHASE

start a new session

create the PROMPT.md file:

    study specs/readme.md
    study specs/analytics-system-implementation-plan.md and pick the most important thing to do

    IMPORTANT:
    - use the ... for ... patterns
    - author property based tests or unit tests (whichever is best)
    - after making the changes to the files, run tests
    - when tests pass commit and push to deploy the changes
    - update the implementation plan when the task is done


run your loop, passing it the PROMPT.md

## Ralph Loop notes

### Plan

You must first have a plan. It should:

1. have a large overview with a list of "phases" or "features"
2. Each "phase"/"feature" should be broken down into tasks
3. Tasks should be broken into steps checklist
4. Each loop should focus on a single task, then update "progress.md" signaling that task is done
5. The loop monitors progress.md and looks for all tasks/features to be done

loop should redirect or tee all agent output to a log file, which the ralph loop can then grep to look for COMPLETED message?

Project
|
|->