# Example · Multilingual request

How meaning survives the language change, and what does not get asked.

---

## Input 1 — Tamil script

> என் வணிகத்திற்கு ஒரு login page வேணும். Email மற்றும் password, மூன்று தவறு attempt பிறகு lock ஆக வேண்டும்.

**Meaning:** I need a login page for my business. Email and password, locked after three failed attempts.

## Input 2 — romanized Tamil mixed with English terms

> என் வணிகத்திற்கு ஒரு login page வேணும். email/password use பண்ணணும், மூன்று தவறு attempt பிறகு lock. என் Node.js + Express project-ல் சேர்க்கவும்.

**Meaning:** I need a login page for my business. Use email/password, locked after three failed attempts. Add it to my Node.js + Express project.

This is how many people actually type. It is not an error and needs no comment.

---

## Stage 1 · Understand

| Status | Item | Source |
|---|---|---|
| `explicit` | login page for the user's business | both |
| `explicit` | email and password | both |
| `explicit` | lock after **three** failed attempts | both |
| `explicit` | existing Node.js + Express project | input 2 |
| `unknown` | where user accounts are stored | — |
| `unknown` | password reset | — |
| `unknown` | whether sessions or tokens | — |

**Preserved verbatim, not translated:** `Node.js`, `Express`, `email`, `password`, the number **3**.

**Modality held:** "வேண்டும்" (needed) is a requirement throughout — it never softened into "if convenient."

## Stage 0 · Anchor

In input 2 the user named the stack. The anchor still has to resolve — the project exists somewhere, and its location is not in the request.

---

## Stage 3 · Resolve

### What must **not** be asked

- What a login page is
- What "three failed attempts" means
- What Node.js or Express are
- Whether a password should be hashed — standard practice, not a user decision

These are either known or conventional. Asking them transfers work the user already did not have to do.

### What gets asked

Delivered in Tamil, because the user wrote in Tamil:

> நீங்கள் கூறியதை புரிந்துகொண்டேன் — email/password மற்றும் மூன்று தவறு attempt பிறகு lock. இரண்டு விஷயங்கள் தெரிய வேண்டும்:
>
> **1 · Users இப்போது எங்கே உள்ளார்கள்?**
> Login செய்வதற்கு ஒரு user list தேவை. நீங்கள் ஏற்கனவே ஒரு database table வைத்திருந்தால், அதைப் பயன்படுத்தலாம். இல்லையா?
> - ஏற்கனவே ஒரு database இருக்கு
> - இல்லை, இதுவே முதல் database
> - **தெரியாது — பார்த்து சொல்லுங்கள்**
>
> **2 · Password மறக்கும்போது என்னா?**
> பெரும்பாலான login pages-ல் "password reset" இருக்கும். இது வேண்டுமா? இருந்தால் email அனுப்ப வேண்டும், அது சற்று வேலையாக இருக்கும்.
> - ஆம், வேணும்
> - இல்லை, தற்போது வேண்டில்லை
> - **தெரியாது — நீங்கள் சிபாரிசு செய்யவும்**
>
> **என் பரிந்துரை:** முதலாவது நீங்கள் project-ல் database இருக்கிறதா என்று நான் பார்க்கிறேன் — நீங்களுக்கு தெரிய வேண்டியதில்லை. இரண்டாவதற்கு reset சேர்த்தால், அது login-ஐ முழுமையாக முடிச்சதாக இருக்கும்.

**Why this shape:** each question names what must be decided, explains the consequence in plain language, offers real options, gives a recommendation with its reason, and allows "தெரியாது" — *I don't know*. The user never has to know what a session strategy is in order to answer.

Note the first recommendation: the compiler will look at the project rather than asking. The user is asked only what a search cannot answer.

---

## Stage 4 · Compile

The prompt goes out in **English** — the default, and what a coding agent reads best. Explanations stayed in Tamil. The two languages are chosen independently.

```text
Add a login page to the existing Node.js + Express application.

Requirements:
- Email and password sign-in.
- Accounts lock after exactly 3 consecutive failed attempts.
- Reuse the project's existing database and user model if one exists. If no
  user store exists yet, create a minimal one following the project's existing
  data-access pattern.

Constraints:
- Follow the existing route, middleware, and error-handling conventions in this
  repository. Match what is already there rather than introducing a new style.
- Passwords must be stored hashed, never in plain text.
- Do not add sign-up, social login, or role handling in this change.

Verify with the project's existing test command. Report what changed and
anything that was left out.
```

---

## What this example is testing

| Check | Result |
|---|---|
| Technical terms preserved | `Node.js`, `Express`, the number `3` |
| Modality preserved | requirement never became optional |
| Explanation language matched | Tamil |
| Prompt language default respected | English |
| Technical questions avoided | no questions a search or convention answers |
| Recommendations offered | both questions carry one |
| Permission to be unsure offered | "தெரியாது" on both |
| Modifiers not hardened | no constraint invented beyond password hashing, which is a safety rule stated with its reason |

**What was not asked, and why it matters.** Nothing here requires the user to understand sessions, hashing, or HTTP status codes in order to answer. They answered two ordinary business questions — where users are stored, and whether password reset is needed — in their own language. That is the whole design.