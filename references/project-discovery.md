# Project Discovery

Stage 0 (Anchor) and stage 2 (Investigate), local side.

Loading conditions: the task depends on a codebase; you are about to read files; the anchor root is not yet established.

**The failure this prevents.** A fluent, well-structured prompt built on the wrong repository. Nothing about the output will look wrong, and the destination agent will confidently edit the wrong code. Confidence is not evidence of correctness.

---

## 1 · Anchor first

Resolve the project root **before** any task-relevant read.

### Resolution ladder

Stop at the first match.

| # | Source | Notes |
|---|---|---|
| 1 | The user named a path | Use it. Verify it exists before relying on it. |
| 2 | `git rev-parse --show-toplevel` | Authoritative repo root. Correct answer for monorepos. |
| 3 | Nearest ancestor with a project marker | `package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `composer.json`, `.git` |
| 4 | Current working directory | Flag it: **"no project detected"** |

**Zero candidates means no project.** Proceed without project context and say so plainly.

**Never fall back to a project you remember** — from earlier in the session, from a previous request, or from a `.agents/` file somewhere else. That fallback is the bug.

### Record the outcome

```
anchor.project_root   absolute, verified to exist
anchor.method         which rung of the ladder
anchor.task_scope     the subtree this task is about
```

If `task_scope` cannot be determined, that is a question for `clarification-and-conflicts.md` — not a guess.

---

## 2 · Repo root vs. task scope

Two different questions. Conflating them is the most common structural error.

| | Answers | Level |
|---|---|---|
| **Repo root** | What is this project? Stack, entry points, major modules. | Whole repository |
| **Task scope** | Which part of it is this task about? | One subtree |

A monorepo has a root holding every workspace config and dozens of subpackages. "This is a Node monorepo with pnpm" is true and useless if the task concerns one package. Report both, at their own altitude.

**Expansion rule:** start at the repo root for orientation, then narrow to task scope. Never scan the entire repo just because you can.

---

## 3 · Anchored reads

- Every search runs **from the resolved root**, never from the working directory.
- If a search returns hits **outside** the root, that is evidence the anchor is wrong. Stop and re-resolve.
- Inspect only what the task needs: the relevant files, their callers, their tests, their configuration.
- Expand only when a new dependency, unexpected behavior, or unresolved question justifies it.

### Stop investigating when

Further reading will not change the prompt, the correctness of a claim, or a material risk. Say what you found; do not keep reading to feel thorough.

---

## 4 · Provenance

Every project fact enters the task record tagged:

```
{ claim, project_root, source_path, verified }
```

This is what makes cross-project isolation checkable at validation time instead of aspirational. If a path cannot be sourced, it does not belong in the prompt.

Label status per `policies.md` §6: `verified`, `inferred`, `recommended`, `unknown`, `conflicting`.

---

## 5 · Paths in the output

The destination agent works in the codebase and resolves paths against its own working directory.

- **Use repo-relative paths by default.** They are shorter and survive a moved checkout.
- **Use absolute paths only** when the target lives outside the repo, or when the user asked.
- **Disambiguate collisions.** If `src/config.ts` appears more than once in the repo, the bare relative path is a bug — it resolves to whichever the destination happens to be in. Prefix with the package or module: `packages/api/src/config.ts`.
- **Verify before citing.** Never name a file you did not read or could not find.

If the task record contains any path outside the anchor root, **stop and ask.** See `policies.md` §5.

---

## 6 · The optional per-project file

`.agents/prompt-compiler/project.md` may exist. It caches what would otherwise be re-derived every session.

**Template:** `assets/project-template.md`

### How to use it

1. Read it **after** anchoring, not before. It may describe a different project than the one you just resolved.
2. Confirm `project_root` in the file matches your anchor. If it does not, **ignore the file entirely** and flag the mismatch.
3. Use it to skip re-derivation, not to replace looking.
4. **Verify the expensive claims.** If it says the test command is `npm test`, confirm that script exists in `package.json` before repeating it into a prompt. A stale command in the prompt is worse than no command — the destination agent will run it and report a false failure.
5. Check `last_verified`. If it is older than recent commits touching the areas it describes, treat it as unverified.

### Rules

- The file is a **hint**. The repository is the truth. On disagreement, the repository wins and the stale line is reported to the user.
- **Never write it automatically.** Only on explicit request.
- Never carry one project's facts into another. Ever.

---

## 7 · Capability awareness

Check what you can actually do before relying on it.

| Missing | Do this |
|---|---|
| File access | Do not claim repository findings. Compile from the request alone and say what you could not verify. |
| Web research | Do not assert current external facts. If they matter, tell the destination agent to verify them if it can browse. |
| Tokenizer | Approximate, only when it actually informs a decision. |
| Subagents | Express workstreams as sequential steps in the single prompt. |
| Shell | Infer structure from files alone, with lower confidence. Label it `inferred`. |

Missing capability changes the prompt's content — it must never change your honesty about what you did.

---

## 8 · Honesty

- Never claim to have inspected a repository, file, page, or result you could not reach.
- Never fabricate a version, path, test result, or citation.
- Say what you examined and what you chose not to, when the omission could change the reader's confidence.

An honest "I could not verify this" is more useful than a confident fabrication.