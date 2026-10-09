# Prompt Compiler

Turn a messy request into **one execution-ready prompt** for a coding agent that works in your codebase.

It asks a few questions, and only the ones that change the result.

```
you:  Add rate limiting to the API

them: What limit would you want? ...
      → "1000/min, 429 when exceeded. Verify with npm test."
```

---

## Install

```bash
git clone https://github.com/<you>/prompt-compiler.git ~/.claude/skills/prompt-compiler
```

Or copy the folder into any skills directory:

| Host | Location |
|---|---|
| Claude Code (personal) | `~/.claude/skills/prompt-compiler/` |
| Claude Code (project) | `.claude/skills/prompt-compiler/` |
| Other agents | `<agent>/skills/prompt-compiler/` |

The skill follows the [Agent Skills](https://agentskills.io) open format — `SKILL.md`, `references/`, `assets/`. Nothing else is required: no backend, no API key, no dependencies.

---

## Usage

Ask plainly, or invoke it directly:

```
/prompt-compiler

Add rate limiting to the API
என் வணிகத்திற்கு ஒரு login page வேணும், மூன்று தவறு attempt பிறகு lock
```

It returns a prompt in a code block, ready to paste. It does not do the work itself.

---

## How it works

| Stage | Does |
|---|---|
| **0 · Anchor** | Resolves which project you actually mean, before reading anything |
| **1 · Understand** | Extracts requirements; handles mixed and romanized languages |
| **2 · Investigate** | Reads only the files that change the answer |
| **3 · Resolve** | Stops and asks when a decision is genuinely open |
| **4 · Compile** | One prompt, only the sections the task needs |
| **5 · Validate** | Eight checks, repair only what is broken |

Two rules cut across all of them, in `references/policies.md`: **never add a constraint you were not given**, and **never remove a requirement to save tokens**.

### Optional per-project file

```bash
mkdir -p .agents/prompt-compiler
cp assets/project-template.md .agents/prompt-compiler/project.md
```

Records stack, test commands, and where things live — so each session stops re-deriving them.

It is a **hint, not the truth.** The repository always wins, mismatched files are ignored, and the skill never writes it on its own.

---

## What it deliberately does not do

- **It does not optimize prompts.** It does not claim your prompt is better phrased than what you would have written. Research has measured a **45% spread** between the best and worst phrasing of the same request, and that spread does not transfer between models or predict from anything you can measure. Phrasing quality is not knowable in advance.
- **It does not add constraints.** Extra rules measurably help weak models and do nothing for strong ones — in one comparison, a heavily constrained prompt scored *identically* to no prompt at all. When the destination model's strength is unknown, adding nothing is the safe default.
- **It does not shorten for its own sake.** Shorter prompts generally perform worse. It removes duplication, never requirements.
- **It does not execute your task.**
- **It does not ask questions it can answer itself.**

### Where its value actually comes from

Not from writing cleverer prose. From the two things that are measurable:

**Asking is worth a lot.** In a published study of underspecified coding tasks, agents that could ask recovered roughly **15 of the 16 points** that underspecification cost them. One self-checking agent reached 61%; splitting detection from execution reached 69%, against a 70% fully-specified ceiling.

**Silent context corruption is the real risk.** A compiler that reads the wrong repository produces a fluent, confident prompt referencing files that do not exist — and never finds out. Stage 0 exists specifically to stop this. See `tests/project-identification.md`.

---

## Limitations

- **No measured overall improvement.** Compiled prompts have not been benchmarked against uncompiled ones end to end. Treat this as good structure and better questions, not a proven upgrade.
- **Output is tuned for agents inside a codebase.** If you paste into a chat AI with no file access, this is the wrong tool — inline code, not paths, is what that target needs.
- **Web research and capability awareness are untrained.** External research was scoped out of v1. The skill is designed to degrade honestly when browsing is unavailable, but that path has not been exercised.
- **Multilingual support is proven for one language only** (Tamil, including romanized and mixed input). Other scripts are handled by the same rules but untested. Say "not sure — you choose" in your language; it will be understood.
- **Reader depth is tuned for beginners.** If you want terse technical output, say so and it will adapt.

---

## Compatibility

| Host | Status |
|---|---|
| Claude Code | Tested |
| Other Agent Skills hosts | Should work — the format is portable and only the six spec frontmatter fields are used. Not verified. |

Requires file access for project-dependent tasks. Degrades honestly without it, without inventing repository findings.

---

## Layout

```
SKILL.md                        entry point
references/policies.md          authoritative — precedence, trust, privacy, permissions
references/task-understanding.md
references/project-discovery.md
references/clarification-and-conflicts.md
references/prompt-composition.md
examples/                       worked examples
tests/                          behavioural tests
assets/project-template.md
```

Each rule has exactly one home. `SKILL.md` states the gate; the reference file owns the detail. They never restate each other.

## Licence

MIT