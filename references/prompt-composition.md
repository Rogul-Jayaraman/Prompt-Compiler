# Prompt Composition

Stage 4 of the workflow. Turn the resolved task record into one unified prompt.

Loading conditions: writing the prompt.

---

## 1 · One prompt

Produce **one** unified prompt covering everything the user asked for.

Use **workstreams** when a task has genuinely distinct parts with dependencies or different verification:

> **Workstream 1 — Data model.** Define the tables and migrations. Blocks 2 and 3.
> **Workstream 2 — API.** Depends on 1.
> **Workstream 3 — UI.** Depends on 2. Independent of nothing.

Rules:

- Order by dependency, and say what depends on what.
- Do not split a single coherent task into workstreams for appearance.
- Name specialist roles only when they change the output. A CSS fix does not need a named team.
- Express delegation as sequential steps when the destination cannot spawn agents.

---

## 2 · Sections are chosen, not mandatory

There is no fixed template. Include a section only when it materially improves the destination agent's chance of doing the task correctly.

### Both extremes fail

Restraint without a floor produces a prompt that adds nothing. Structure without judgment produces a template. Both are failures.

**Floor — the prompt must earn its existence.** If your output could have been produced by copying the user's request, you did not compile. Contribute at least one thing the user did not supply: an ambiguity you resolved, an implication you drew out, a value that was left open, or a consequence they had not considered.

Ask yourself: *would the destination agent do something different, or know something it did not, because of my prompt?* If not, either add that — or say plainly that this task needed no compilation, and return the request unchanged on purpose rather than by omission.

**Ceiling — no scaffolding.** Do not emit section headers the task does not need. `## Objective / ## Deliverables / ## Requirements / ## Notes` on a one-line task is a failure, not thoroughness. Do not restate the same requirement under two headings. Do not include a `Notes` section about your own process.

| Include | When |
|---|---|
| Objective and deliverables | The expected outcome is not obvious from the rest |
| Project context and file paths | The task touches an existing codebase |
| Research findings and sources | External evidence changes the approach |
| Constraints and exclusions | Scope drift or invalid solutions are likely |
| Workstreams and order | There are real dependencies |
| Acceptance criteria | Completion needs an observable definition |
| Testing and verification | The change is verifiable |
| Safety and approval boundaries | Real operational or security risk |
| Output format and reporting | A specific final deliverable was requested |

A small task needs one or two of these. Including all nine every time is a failure, not thoroughness.

**The test:** does this instruction materially improve the destination agent's ability to finish correctly? If not, cut it.

---

## 3 · Default-deny on constraints

**Add no constraint the user did not state.**

- Carry their constraints over intact, in their terms.
- Do not invent requirements to make the prompt look professional.
- Do not restate what the destination agent already does by default.
- Do not harden a preference into a rule.
- Keep optional things visibly optional.

*Evidence note:* piling extra rules onto a strong model does not make it stronger. In a measured comparison, a heavily-constrained prompt scored **exactly the same as no prompt at all** on a strong model, while the same constraints helped a weaker one. Extra rules are not free. When the destination model's strength is unknown — usually — the safe default is to add nothing.

**Exceptions.** Add a constraint only when a real risk requires it and you can say why:

- A destructive action needs confirmation.
- A secret must not be printed.
- The user asked for production-grade work and the constraint is implied by that.

State the reason in the prompt.

---

## 4 · Execution boundaries

Say what the destination agent should do **and should not do**.

- Analysis requested → do not tell it to modify files.
- Implementation requested → include verification steps.
- Authorization unclear → require approval before the consequential action.
- Do not instruct it to bypass its own governing rules or approval controls.

---

## 5 · The destination has the repository

The prompt goes to an agent working in the codebase.

**Do not paste file contents.** It can read them, and pasted code goes stale the moment anything changes. Reference paths instead.

**Do not answer the question inside the prompt.** If the user asked for analysis, the prompt asks for analysis — it does not contain the analysis. Writing findings, conclusions, or a summary of what you discovered into the prompt is doing the task yourself, which is the one thing this skill never does.

Include only what it cannot obtain: exact versions, decisions and their reasons, constraints that are not visible in the code, and things that look wrong but are intentional.

Exception — paste content when the file is **outside** its reach, or when a precise snippet is the actual subject (a regex, a config value, an error string).

Paths: repo-relative by default, disambiguated when they collide. See `project-discovery.md` §5.

---

## 6 · Length

Optimize useful information, not characters.

**Remove:**
- Duplicated requirements
- Generic filler
- Context the destination agent already has
- Restatements of a rule already in its own instructions

**Keep, always:**
- Exact identifiers, paths, versions, values
- Constraints that are non-obvious
- The specific thing that went wrong last time

**Never remove a requirement to shorten the prompt.** Compression removes meaning, not just words. There is no token budget formula here — a fixed budget pushes the compiler into cutting requirements it should have kept.

*Evidence note:* shorter prompts generally perform **worse**, not better. The unit of removal is duplicated or generic text, never a requirement.

---

## 7 · Acceptance criteria

Include when the task is verifiable and "done" is otherwise ambiguous.

Make them observable:

- The reported failure is reproduced, or its cause is identified.
- The fix addresses the cause without breaking existing behavior.
- Relevant tests pass — or remaining gaps are reported.

Do not invent testing requirements for tasks where they make no sense. "Write a thank-you note" needs no verification section.

Avoid vague targets: "make it perfect", "optimize everything", "clean and professional".

---

## 8 · Output

- English by default. Another language only if the user asks.
- One fenced code block, ready to paste.
- No preamble, no summary of your process, unless asked.
- Do not execute the task.