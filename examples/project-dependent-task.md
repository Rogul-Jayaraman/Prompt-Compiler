# Example · Project-dependent task

A request that looks simple, hides a decision, and depends on what the code already does.

---

## Input

> Add rate limiting to the API.

---

## Stage 0 · Anchor

| Field | Value |
|---|---|
| `project_root` | resolved via `git rev-parse --show-toplevel` |
| `method` | ladder rung 2 |
| `task_scope` | `src/api/` |

Repo is a Node service. Task scope is the API layer.

## Stage 1 · Understand

| Status | Item |
|---|---|
| `explicit` | rate limiting on the API |
| `unknown` | which endpoints, what limit, per what window |
| `unknown` | response when exceeded (429? plain error?) |

## Stage 2 · Investigate — effort: targeted

Overridable by project context. What matters is that each read answered a question.

| Read | Question it answered |
|---|---|
| `package.json` | Is there a rate-limit library already? No. |
| `src/api/server.ts` | Where routes are registered — the single choke point. |
| `src/api/middleware/` | Existing middleware pattern to match. |
| `src/api/routes/orders.ts` | Does anything already throttle the heaviest route? No. |

Stopped here. Reading the other route files would not change the prompt.

## Stage 3 · Resolve — **hard stop**

Two decisions would materially change the output, and neither is visible in the code:

1. **How many requests?** The code has no traffic baseline.
2. **Which behaviour when exceeded?**

### What gets asked

> Before I write this, two things would change the result and I can't tell either from the code.
>
> **1 · How many requests should be allowed?**
> This sets the threshold. Too low and real users get blocked; too high and it doesn't really protect anything.
> - About 100 requests per minute
> - About 1000 per minute
> - Different limits for sign-in and normal use — more complex, but sign-in is the one worth protecting
> - **Not sure — pick something sensible for a small service**
>
> **2 · What should happen when someone goes over?**
> - Blocked with a clear "slow down" message
> - Blocked silently
> - Queued until the limit clears
>
> **My suggestion:** 1000 per minute for normal use, a much lower limit for sign-in, and a clear message when blocked. That protects the login route without getting in the way of normal browsing.

Both questions explained, both with options, a recommendation given, and permission to decline offered.

## Stage 4 · Compile

Sections included: objective · project context · constraints · verification · acceptance criteria.

**Not** included: workstreams (single coherent task) · research findings (none) · safety boundaries (none beyond the user's own).

### Output

```text
Add rate limiting to the API in this repository.

Context: Express app. Routes are registered in src/api/server.ts, and existing
middleware follows the pattern in src/api/middleware/. There is no rate-limit
library in package.json yet — add one, and match the existing middleware style.

Rules:
- 1000 requests per minute per IP for normal API routes.
- 10 requests per minute for the sign-in route.
- Exceeding a limit returns HTTP 429 with a plain-language message naming the
  limit and when it resets.
- Count per IP, in memory, matching the existing middleware pattern. No new
  external service.

Verify: `npm test` passes, and a request beyond the limit returns 429.

Do not change route behaviour otherwise.
```

### What was deliberately left out

- **No "add tests if possible."** The user did not ask.
- **No in-memory-store caveat.** It is the user's stated choice, not something to hedge.
- **No section on deployment.** Not requested, and nothing in the task implies a rollout.

*Evidence note:* the constraint set here is entirely the user's. The only line added on the compiler's own initiative is the 429 status code — required for "a clear message when blocked" to mean anything, and explained inline.

---

## What makes this example work

The compiler did not open every route file. It stopped at four targeted reads because further reading would not change the prompt.

And it did not quietly pick a rate limit. A wrong guess here is invisible until production — the exact failure mode where a confident, fluent, wrong prompt is most expensive.