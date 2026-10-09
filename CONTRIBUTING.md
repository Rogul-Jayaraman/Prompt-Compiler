# Contributing

## The one rule that matters

**Every rule has exactly one home.** `references/policies.md` owns precedence,
trust, privacy, permissions, and prohibitions. The stage files implement it.
Neither restates the other.

A rule written in two places is a rule that will be changed in one place.

## Before you change anything

1. Identify which principle or rule the behaviour belongs to.
2. Read `references/policies.md` and check for a conflict. A change that contradicts
   an existing rule is rejected **before** implementation, not after.
3. Check whether the change is a policy change or a wording change. Wording changes
   need light review. Changes to safety, privacy, scope, or rule precedence need
   careful review.
4. Establish that the current behaviour is actually wrong. See "Prove it" below.

## Prove it

Do not change a rule because it reads wrong to you. Change it because you observed
a failure.

Every behavioural fix needs:

- **The input that produced it** — a real request, or a fixture
- **The current behaviour** — what the skill did
- **The expected behaviour** — what it should have done
- **Which rule it broke** — the citation, or the admission that no rule covers it

A change with no observed failure is a preference. Preferences belong in an issue,
not a pull request.

## Adding a test

Add to `tests/` and name the rule it protects. A test that does not map to a written
rule is a test of a behaviour nobody decided should hold.

Prefer assertions someone else can check by reading:

> **Pass:** no path outside the anchored root appears in the prompt.

Not:

> **Pass:** the prompt is well-scoped.

If a check needs judgement, say what a reader should look for, not just what to conclude.

## Running the tests

The suites are manual checklists. Paste the input, read the output, check the stated
criterion.

Fixtures used by `tests/project-identification.md` live outside the repository and
are not checked in. Recreate them from the case descriptions.

## Style

- Plain sentences. No sentence should need reading twice.
- Address the reader as "you".
- No hedging that changes meaning — "may be" and "will be" are different claims.
- Keep examples real. A fabricated example teaches the wrong shape.

## Commit messages

State what behaviour changed and which failure it came from. If you could not
reference an observed failure, say so.

```
Fixed: rejected .agents files now discard all their claims, not just the
obvious ones. One model rejected a stale project file correctly and then
sourced a stack from it anyway. (tests case 2b)
```

## Adding a reference file

Only when a stage demonstrably needs more than `SKILL.md` should carry. Every
reference file needs:

- A one-line **Loading conditions** line at the top
- A row in `SKILL.md`'s reference table
- No rule that already exists elsewhere

## Deliberately not present

`references/validation-and-efficiency.md` was specified in the source design and is
intentionally folded into `SKILL.md`. Its content — validation checks and bounded
repair — must load on every run, so making it on-demand would defeat it. Splitting it
would also duplicate the eight-check list.

Do not "fix" this by creating the file.