# Solutions

**Candidate:** Piyaphong
**Branch / repo:** [frontend_dev_challenge](https://github.com/piyapong-ukoad/frontend_dev_challenge.git)
**Flutter:** 3.27.0 · **Java:** 17

## Summary

| Item | Status | Commit(s) |
| --- | --- | --- |
| RES-101 Search shows wrong query results | | |
| RES-102 Crash after leaving My orders | | |
| RES-103 Requests pile up | | |
| RES-104 Duplicate deals in home feed | | |
| RES-105 Janky feed / memory growth | | |
| RES-106 Wrong pickup times | | |
| RES-107 Deep link crash | | |
| F-1 Flash-sale countdowns | | |
| F-2 Impression tracking | | |
| F-3 Stock reservations | | |

*Only the items I worked on are described below.*

---

## Part A: Bug tickets

### RES-10X · <ticket title>

**How I reproduced it**

- Steps, console logs, or screenshots.

**Root cause**

- What was actually wrong (the mechanism, not just what I changed).
- File and line references, e.g. `lib/feature/search/search_controller.dart`.

**Fix**

- What I changed and why this addresses the cause, not just the symptom.

**Alternative considered and rejected**

- Alternative: ...
- Why I rejected it: ...

**Edge cases**

- Handled: ...
- Deliberately not handled (and why): ...

**Evidence** *(required for RES-105)*

- Before: DevTools screenshot or numbers.
- After: DevTools screenshot or numbers.

---

## Part B: Features

### F-X · <feature title>

**Approach**

- Short description of the design.

**Why this design**

- Reasoning, with performance considerations (e.g. scope of rebuilds).

**Alternative considered and rejected**

- Alternative: ...
- Why I rejected it: ...

**Edge cases**

- Handled: ...
- Not handled: ...

**Verification**

- How I tested it (Analytics debug screen, DevTools rebuild counts, manual steps).

### F-3 only: product decision on reservation expiry

- **What happens when a reservation expires while the user is in the app / mid-checkout:** ...
- **Why this is the right behaviour for users:** ...
- **Options I rejected and why:** ...

---

## Part C: AI usage log

### Tools used

- <Tool>: <what I used it for>

### How I used AI

- e.g. explaining unfamiliar GetX behaviour, reviewing my own hypotheses, boilerplate.
- How I verified AI output (reproducing in the app, console logs, DevTools).

### Example 1: AI suggestion was wrong or misleading

- **Ticket / feature:**
- **What the AI suggested:**
- **Why it was wrong:**
- **How I caught it:**
- **What I did instead:**

### Example 2: AI suggestion was wrong or misleading

- **Ticket / feature:**
- **What the AI suggested:**
- **Why it was wrong:**
- **How I caught it:**
- **What I did instead:**

---

## Part C: Design questions

### Q1. `GetxController` lifecycle vs widget `State` lifecycle

*(Difference between the two. Name one Part A bug caused by confusing them.)*

<answer>

### Q2. When does one large `Obx` hurt?

*(How do I decide how tightly to scope reactivity?)*

<answer>

### Q3. How would I test for RES-106?

*(What test would have caught it, and what code changes would make it testable?)*

<answer>

---

## Time spent

| Item | Approx. time |
| --- | --- |
| Setup | |
| RES-10X | |
| F-X | |
| Writing this document | |
| **Total** | |

## What I would do next with one more day

- ...
