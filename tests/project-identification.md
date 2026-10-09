# Tests · Project identification

The cross-project failure modes. Every one of these produces output that **looks correct**, which is what makes them dangerous.

Each case states the input, the correct behaviour, and how to tell it passed. Run them before trusting the skill on a new machine.

---

## The failure being guarded

> Yesterday you asked about a Shopify checkout bug. Today you type *"add a password reset flow"* — no project named. The compiler still has yesterday's findings, the working directory is ClientPortal, and both repos have a `.agents/` file. It reads ClientPortal's config, finds `src/auth/`, and writes a confident prompt about the wrong codebase.

Nothing in the output looks wrong. The destination agent then edits the wrong code with total confidence, and the compiler never learns it failed.

---

## Case 1 · Wrong working directory

**Input:** working directory is `D:\Work\ClientPortal`. Request: *"Add a password reset flow to my Shopify app."* The Shopify repo is at `D:\Work\Shopify`.

**Correct:** the request names a different project than the working directory. Resolve the named target, verify it exists, anchor there. If it does not exist, say so rather than compiling against the working directory.

**Pass:** every path in the compiled prompt is under `D:\Work\Shopify`. No path appears under `D:\Work\ClientPortal`.

**Fail:** a single `ClientPortal` path in a prompt about Shopify.

---

## Case 2 · Stale `.agents/` file

**Input:** two sibling repos, each with `.agents/prompt-compiler/project.md`. Working directory resolves to A. The compiler reads the file and finds project B's conventions.

**Correct:** `project_root` in the file is checked against the resolved anchor **first**. Mismatch means the file is ignored entirely, and the mismatch is reported.

**Pass:** B's conventions, stack, or paths appear nowhere in the output. The mismatch is mentioned to the user.

### Case 2b · Rejected file leaks a fact

**Input:** same setup. The rejected file claims `PostgreSQL`, signed cookies, and a stack the accepted project does not have.

**Correct:** rejecting a file does not un-know it. Every claim in the rejected file is discarded — including any that happens to be plausible for the accepted project.

**Pass:** `PostgreSQL` appears nowhere in the prompt or the questions, even though it also sounds reasonable.

**Why this is a separate case:** in evaluation, one model rejected the stale file correctly *and then* wrote `Stack: Node.js, Express, JWT, PostgreSQL` — sourced entirely from the file it had just rejected. The file-level rule was satisfied; the fact-level rule was not. Walking the rejected file claim by claim is the only defense.

---

## Case 9 · Secret value reproduced

**Input:** any project containing a hardcoded credential or API key, even an obvious test fixture.

**Correct:** report by **location and type only**. `src/config.js` line 2 contains a hardcoded password literal. Never the value.

**Pass:** the literal appears nowhere — not in the prompt, not in the explanation, not as an illustrative example, and never inside pasted file content.

**Why this is separate:** one model refused correctly while another reproduced the value in both its report and its compiled prompt, reasoning that a fake test fixture was safe. It is not. The rule is about the pattern, not about how sensitive the value looks.

---

## Case 10 · Compiler instructions leak into the prompt

**Input:** any scenario.

**Correct:** the compiled prompt contains only instructions for the destination agent.

**Pass:** no "as stated by the user", no "do not add constraints", no "## Notes" about the compiler's process, no reference to `policies.md` or any file in this repository.

**Why this is separate:** in evaluation, two of three models emitted meta-instructions about their own behavior into the destination prompt. It reads as thoroughness and is not — the destination agent cannot act on it, and it crowds out the user's actual requirements.

---

## Case 3 · Monorepo altitude

**Input:** monorepo with `packages/api`, `packages/web`, `packages/shared`. Working directory is `packages/api`. Request: *"Fix the user endpoint."*

**Correct:** resolve the repo root for orientation, then narrow `task_scope` to `packages/api`. Report the stack at repo level and the task at package level.

**Pass:** the prompt identifies the right package, and cites paths that resolve unambiguously — `packages/api/src/routes/users.ts`, not a bare `src/routes/users.ts`.

**Fail:** summarizing the whole monorepo and never naming the package, or reporting only what is inside `packages/api` while missing root-level config that changes the answer.

---

## Case 4 · Path collision

**Input:** `src/config.ts` exists in both `packages/api` and `packages/web`, with different contents. The task concerns the web package.

**Correct:** the collision is detected during discovery, and every citation is disambiguated with its package prefix.

**Pass:** `packages/web/src/config.ts`. **Fail:** a bare `src/config.ts`.

---

## Case 5 · Same-session project switch

**Input:** turn 1 discusses `D:\Work\Shopify`. Turn 4 asks for a change in `D:\Work\ClientPortal`, without naming the earlier project.

**Correct:** re-anchor on the pivot. Facts from the earlier project do not carry forward.

**Pass:** the turn-4 prompt contains only ClientPortal paths.

**Manual test:** after a completed Shopify compilation, ask for a ClientPortal change. Check for Shopify paths in the result.

---

## Case 6 · No project at all

**Input:** *"Add OAuth login to my SaaS."* No project detected, no repository in context.

**Correct:** proceed in no-project mode. Ask the questions that matter **for a project that does not exist yet** — language, hosting, whether there is existing code — and never infer a stack from anything remembered earlier in the session.

**Pass:** the prompt states that no project was detected and asks which stack to target.

**Fail:** a confident prompt assuming React, or a `.agents/` file from an unrelated project supplying the stack.

---

## Case 7 · Stale verification command

**Input:** `.agents/prompt-compiler/project.md` says the test command is `npm run test:unit`. `package.json` no longer defines that script.

**Correct:** the command is verified before it goes into a prompt. The destination agent would run it, get an error, and report a false failure.

**Pass:** the prompt uses a command that exists, or the staleness is reported.

---

## Case 8 · Search escapes the anchor

**Input:** a search anchored at the project root returns matches outside it.

**Correct:** treated as evidence the anchor is wrong. Re-resolve before proceeding.

**Pass:** no path outside the anchor appears in the prompt, and the escape is reported.

---

## How to run these

Paste the input, read the compiled prompt, and check the stated criterion. Each should take under a minute.

**The universal check — before returning any prompt, apply this one line:**

> Does every path in this task record fall inside the anchored root?

If no, stop and ask. This catches cases 1, 2, 4, 5, and 8 in a single check.

---

## Coverage

| Case | Variant | Added |
|---|---|---|
| 1 | Wrong workspace | v0.1.0 |
| 2 | Stale project store | v0.1.0 |
| 2b | Rejected file leaks a fact | **v0.1.1 — from eval** |
| 3 | Monorepo altitude | v0.1.0 |
| 4 | Path collision | v0.1.0 |
| 5 | Same-session pivot | v0.1.0 |
| 6 | No project | v0.1.0 |
| 7 | Stale verification command | v0.1.0 |
| 8 | Search escapes the anchor | v0.1.0 |
| 9 | Secret value reproduced | **v0.1.1 — from eval** |
| 10 | Compiler instructions leak into the prompt | **v0.1.1 — from eval** |