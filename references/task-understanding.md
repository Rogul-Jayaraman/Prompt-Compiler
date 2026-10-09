# Task Understanding

Stage 1 of the workflow. Turn the raw request into a working task record.

Loading conditions: extracting intent from a request; any non-English, romanized, or mixed-language input.

---

## 1 · What to extract

| Field | Meaning |
|---|---|
| `objective` | What the user wants to accomplish |
| `deliverables` | The concrete outputs expected |
| `requirements` | Stated functional and non-functional requirements |
| `constraints` | Boundaries — stack, budget, format, permissions, deadlines |
| `exclusions` | What must not be included or done |
| `preferences` | Output language, depth, format |
| `environment` | Target agent and its known limitations |
| `evidence[]` | Discovered facts — see `project-discovery.md` |
| `assumptions[]` | Unconfirmed, with the impact if wrong |
| `open_questions[]` | Material ambiguities still unresolved |
| `conflicts[]` | Requirements that cannot all hold |

Not every field needs filling. "Rewrite this sentence professionally" needs an objective and nothing else.

**Do not invent requirements to fill an empty field.** An empty field is information.

---

## 2 · Preserve exactly

These carry meaning and must survive compilation untouched:

- **Names** — people, files, functions, brands, packages
- **Numbers** — counts, versions, limits, prices, dates
- **Paths** — exactly as written, including case
- **Negation** — "do not", "without", "stop using"
- **Modality** — the difference between must, should, may, and optional

An optional requirement must never become mandatory. "Add tests if convenient" must not compile into "write tests."

---

## 3 · Status labels

Every requirement and every fact carries one. These are labels, not a database.

| Label | Meaning |
|---|---|
| `explicit` | Stated directly by the user |
| `clarified` | Confirmed or corrected by the user in reply |
| `inferred` | Reasoned from available evidence |
| `recommended` | Proposed by you, not yet accepted |
| `unknown` | Not established |
| `conflicting` | Sources or requirements disagree |

**A `recommended` item is never presented as a user decision.** This is the single most common way a compiled prompt misleads its reader.

---

## 4 · Multilingual input

The host model reads whatever language the user writes in. Your job is to hold the meaning steady across the translation.

### Rules

1. **Understand any language, including romanized and mixed.** Users often type one language in Latin script with English technical terms. That is normal, not an error.
2. **Preserve technical terms verbatim.** Package names, CLI flags, error strings, and identifiers are not translated — not even ones that look translatable.
3. **Two output languages, independently.** The *prompt* comes out in English by default. Your *explanations and questions* match the language the user wrote in.
4. **Unless the user asks for another output language,** the prompt is English.
5. **Never lose modality in translation.** "Must" must not soften into "should."
6. **Preserve numbers and units** exactly, including local number formats.

### Handling negation and hedging

Translation tends to *strengthen* claims. Watch for these:

| Original intent | Do not emit |
|---|---|
| "I think it might be the cache" | "The problem is the cache" |
| "Don't use Redis unless needed" | "Do not use Redis" |
| "probably fine to change this" | "Change this" |

When you are unsure whether a claim was hedged, keep the hedge. Overstatement is a fidelity failure.

### Worked example

> என் வணிகத்திற்கு ஒரு login page வேணும் — email மற்றும் password, மூன்று தவறு attemptக்கு பிறகு lock

**Read as:** a login page for my business — email and password, locked after three failed attempts.

**Requirements extracted:**

- `explicit` — login page for the user's business
- `explicit` — email and password fields
- `explicit` — lock after 3 failed attempts
- `explicit` — implied: the user has an existing business application
- `unknown` — which framework, where it should live, what the lock duration is

**Ask** — the framework and lock duration. Do **not** ask what a login page is, or what "three failed attempts" means. Those are answered.

### Normalization

You may normalize spelling, casing, and phrasing to reason clearly. You may not add requirements or drop meaning.

Keep the original request reachable. The normalized version is a working view, not a replacement.

---

## 5 · Context from the conversation

Use prior context only when relevant and not superseded. A newer correction beats an older preference.

If the user has already decided something this session, do not ask again. If the target project changed, re-anchor — see `project-discovery.md`.

---

## 6 · What not to do

- Do not rewrite an unclear request into a more specific task without evidence. That silently substitutes your goal for theirs.
- Do not infer a technical domain from a single keyword.
- Do not assume a question is needed. Most requests need none.
- Do not treat silence as agreement on anything you guessed.