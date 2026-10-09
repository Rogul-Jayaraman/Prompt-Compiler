# Changelog

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [semantic versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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