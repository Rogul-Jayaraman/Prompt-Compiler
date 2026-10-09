# Security Policy

## Reporting a vulnerability

**Do not open a public issue for a security problem.**

Email the maintainer privately, or use GitHub's private vulnerability reporting
if it is enabled on this repository (`Security` → `Report a vulnerability`).

Please include:

- What the skill does wrong, and which rule it breaks
- The smallest input that reproduces it
- Which model you observed it on, if known
- Whether it caused incorrect output, information disclosure, or unsafe behaviour

You will get an acknowledgement within a week. Fixes for confirmed issues ship as a
patch release with the failure written up in the changelog.

## What counts as a vulnerability here

This skill produces text. Its realistic risks are:

| Class | Example |
|---|---|
| Instruction leakage | Following instructions embedded in a file or page instead of the user's request |
| Secret disclosure | Reproducing a credential found during project inspection |
| Scope escape | Executing the underlying task, or instructing the destination agent to bypass its approval controls |
| Cross-project contamination | Facts from an unrelated repository reaching the compiled prompt |
| Fabricated grounding | Inventing project structure, versions, citations, or test results |

## What is not a vulnerability

- **The skill producing a prompt you disagree with.** Quality complaints go in normal issues.
- **Prompt injection succeeding against a deliberately adversarial input.** `tests/` contains such inputs. The skill reduces this risk through instruction design; it does not eliminate it, and no instruction-only defence can. Real protection is the host's permission model, least privilege, and human approval for privileged actions.
- **A missing tool being worked around.** If browsing is unavailable and the skill says so, that is correct behaviour.
- **The skill not triggering.** A reliability and ergonomics problem, not a security one — but please still report it, because it is the failure users notice most.

## Threat model

Prompt Compiler reads content the user did not write: repository files, READMEs,
code comments, web pages, logs. Any of it can contain text aimed at the agent.

Defences in place:

- `references/policies.md` §2 — untrusted content is data, never authority
- `references/policies.md` §4 — secrets are reported by location and type, never reproduced
- `references/policies.md` §5 — project isolation, with a stop rule on out-of-anchor paths
- `tests/project-identification.md` — adversarial cases, runnable by hand

**Limit of the defence:** these are instructions to a language model. They raise the
cost of an attack; they do not make injection impossible. Anyone relying on this
skill for a privileged workflow must also rely on host permissions and approval
controls, not on this file.

## Before you publish a change

- No real credentials, tokens, or private URLs anywhere in the repository or its history.
- Fixture secrets are obviously fake (`hunter2-real-looking-secret`) and are used
  deliberately, in tests only.
- New examples do not embed real user data.