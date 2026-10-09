# Project context — optional

<!--
  Copy this file to:  .agents/prompt-compiler/project.md
  Fill in what you know. Delete anything you do not know — an empty field is
  useful information; a wrong one is not.

  Prompt Compiler reads this to avoid re-deriving the same facts every session.
  It is a HINT, not the truth. The repository always wins on any disagreement,
  and Prompt Compiler says so when it spots a mismatch.

  Prompt Compiler never writes this file on its own.
-->

## Identity

project_root: /absolute/path/to/repo
last_verified: YYYY-MM-DD

<!-- Must match the repo it sits in. If it does not, the file is ignored. -->

## What this is

<!-- Two or three lines. What the project does, who uses it. -->

## Stack

<!-- Languages, frameworks, key libraries, notable version pins. -->

## Verification commands

<!--
  The commands that prove the work is correct.
  Prompt Compiler checks these still exist before repeating them.
-->

- install:
- run / dev:
- test:
- lint:
- build:

## Where things live

<!-- Task type -> location. Saves the destination agent guessing. -->

| Looking for | Path |
|---|---|
| Example: auth code | `src/auth/` |
| Example: its tests | `tests/auth/` |
| Example: config | `src/config.ts` |

## Conventions

<!-- Patterns a new change must match: naming, error handling, test style,
     import style, how modules are structured. -->

## Boundaries

<!--
  Forbidden paths, approved sources for dependencies, deployment targets,
  the names (never the values) of any environment variables or secret locations.
-->

## Landmines

<!--
  Flaky tests, legacy code that looks wrong but is not, files that look
  abandoned but are not. Anything that would otherwise cost a future session
  an hour to rediscover.
-->