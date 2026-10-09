# Trigger evaluation

The highest-frequency real-world skill failure is invisible: **the skill never
loads.** Everything else in `evals/rules.json` assumes the skill is already
active. This suite tests the thing that decides whether it gets that far — the
`description` field in `SKILL.md` frontmatter.

Twenty queries, half that should load the skill and half that must not. The
negative half is built from near-misses with real lexical overlap, because that is
where descriptions break:

| Trap | Why it looks like a trigger |
|---|---|
| "Write a prompt for Stable Diffusion…" | Contains "write a prompt" |
| "Improve the system prompt in `src/prompt.ts`" | Contains "prompt" and is a coding task |
| "Add rate limiting to the API" | Is exactly the kind of task the skill *writes prompts for* |

A good description routes 1–8 to the skill and refuses 9–20.

## Method

Split 60/40 train/test. Tune the description against the 8 train queries, then
measure once on the 12 held-out queries. Reporting a number on the queries you
tuned against measures nothing.

## Scoring

Each query gets `should_load: true|false`. A model answers which, given only
the description and the query. Score:

```
recall    = correctly loaded / 10 should-load
precision = correctly refused / 10 should-refuse
```

Both must clear **90%**. A description with high recall but poor precision fires
on unrelated work, which is worse than never firing — the user gets an unwanted
skill activation and an unwanted preamble.

Report train and test separately. If they diverge sharply, the description was
overfit to the train split.

## Running it

Paste the description and the queries to a model with no access to the skill:

```
Here is a skill description:

<description>

For each numbered user query below, answer LOAD or SKIP — would an agent
invoke this skill? Answer with the number and LOAD or SKIP only.

<queries>
```

Scoring:

```powershell
powershell -File evals/triggers.ps1 -File <responses.txt>
```

Responses are one per line: `1 LOAD`, `2 SKIP`, …

## Known limitation

This measures description-to-query match, not real host routing. Hosts rank
skills with their own embedding and selection logic, and some add system prompt
context that changes the decision. Treat the result as an upper bound on trigger
quality, not a substitute for observing the skill actually fire in a real
session.