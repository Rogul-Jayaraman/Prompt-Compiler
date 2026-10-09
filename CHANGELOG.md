# Changelog

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.4] — 2026-10-09

### Fixed
- **The hard stop fired on conflicts but not on material unknowns.** Two models compiled
  past *"add a login form to an app with no user store and no server"*, hedging with
  *"if there is no user store, report that instead."* That defers a guess to the far end
  of the workflow, where it is harder to see. `SKILL.md` now names the four tells of a
  deferred guess, and a missing dependency is an explicit ask trigger.
  Validated at 100% across `big-pickle`, `step-5` and `ling-3.1-flash`.
- **Trigger over-fire on direct tasks.** The description ended with *"Not for executing
  the task itself"*, which lost to the leading positive phrasing. One model in two read
  *"Add rate limiting to the API"* as a trigger — the exact kind of task this skill
  writes prompts *for*. The exclusion is now promoted and names the trap directly.
  Trigger accuracy went from 19/20 to **40/40** across both models on both splits.

### Known limitations
- **Single trial per scenario.** `pass^k` is designed for and never run at k>1.
- **No with-skill vs without-skill baseline.** It remains unmeasured whether this skill
  beats simply asking the destination agent directly. That is the claim a user would
  actually care about.
- **Mid-tier models only.** No frontier model tested. `nemotron-3.5-lightning-free`
  could not be scored — it returned prose summaries instead of the required output
  format, twice.
- **Results were hand-transcribed.** Two transcription errors were caught (a Tamil
  codepoint, and dropped lines that made a correct output look like a failure). A
  harness with a human in the capture path is not a harness.

## [0.1.3] — 2026-10-09

### Added
- `SECURITY.md`, `CONTRIBUTING.md`, `references/web-research.md`.
- `evals/` — deterministic evaluation harness. No LLM-as-judge on the primary path,
  following SkillsBench design guidance (arXiv:2602.12670).
- `evals/triggers.ps1` — trigger accuracy with a 60/40 train-test split, so the
  description is never scored against queries it was tuned on.

### Added (spec gaps)
- Effort is revisable. Escalate or reduce as evidence changes.
- Explain any unrecognised term at first use.
- Never imply the user must understand the technology to decide validly.

### Fixed
- `policies.md` pointed at `CHANGELOG.md`, which did not exist.

## [0.1.2] — 2026-10-09

### Added
- Distinguish what the user wants: prompt only, prompt plus explanation, or the task
  executed. The skill had no rule for telling these apart.
- Task record now carries `context`, `workstreams` and `acceptance_criteria`.
- **Research resolves facts, it cannot resolve preference.** The most load-bearing
  rule in Investigate was missing entirely.
- Effort is revisable — escalate or reduce as evidence changes.
- Explain any unrecognised term at first use; never imply the user must understand
  the technology to decide validly.
- Validation check 9: does the prompt add something the raw request did not have?
- Validation check 10: did accompanying text match the user's language?
- Validation check 11: does the prompt say to report a missing dependency?
- Accessible prompts: required, optional and prohibited instructions must be
  visually distinguishable; coined terms get defined; examples appear when they
  remove ambiguity.
- Progressive explanation: asking for more detail is never gated behind a
  clarifying question.

### Fixed
- `policies.md` pointed at `CHANGELOG.md`, which did not exist.

## [0.1.1] — 2026-10-09

Behavioural evaluation across three free models. Scores 15/15, 14/15, 7/15.
The spread was the finding: prohibitive and structural rules held on every model,
judgement rules did not.

### Added
- The compiled prompt must contain only instructions for the destination agent.
  Two of three models leaked meta-instructions ("as stated by the user", "do not
  add constraints") into the prompt.
- Secrets are reported by location and type, never reproduced. One model repeated a
  hardcoded credential in both its report and its compiled prompt, reasoning that a
  test fixture was safe.
- Rejecting a source discards its content. One model rejected a stale project file
  correctly and then wrote a fact sourced entirely from it.
- Only literally user-supplied content may be labelled user-stated.
- Composition floor: the prompt must earn its existence. Restraint had no lower
  bound, so one model echoed the request verbatim while another forced a rigid
  template. Both extremes are now explicit failures.
- Materiality is defined rather than left to judgement. Conflicts must be
  enumerated before asking — one model caught one of two and silently compiled the
  other.

### Added (tests)
- Cases 2b, 9, 10 for the three failures found in evaluation.

## [0.1.0] — 2026-10-09

Initial release.

### Added
- Six-stage workflow: Anchor, Understand, Investigate, Resolve, Compile, Validate.
- `references/policies.md` as the single authoritative rule owner.
- Stage references for understanding, discovery, clarification, and composition.
- Cross-project anchoring, added after identifying that a prompt built on the wrong
  repository fails silently and confidently.
- Worked examples: project-dependent task, multilingual request (Tamil).
- `tests/project-identification.md`.
- Optional per-project context file at `.agents/prompt-compiler/project.md`.

### Known limitations
- No measured end-to-end improvement over asking directly.
- External research designed for, not implemented, in this version.
- Multilingual handling proven for Tamil only.
- Targeted at agents working inside a codebase, not chat AIs without file access.