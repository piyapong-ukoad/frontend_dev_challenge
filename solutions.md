# Solutions

**Candidate:** Piyaphong
**Branch / repo:** [frontend_dev_challenge](https://github.com/piyapong-ukoad/frontend_dev_challenge.git)
**Flutter:** 3.27.0 · **Java:** 17

## Summary

| Item | Status | Commit(s) |
| --- | --- | --- |
| RES-101 Search shows wrong query results | partial | |
| RES-102 Crash after leaving My orders | done | 5fc061d |
| RES-103 Requests pile up | done | 3557302 |
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

### RES-101 · Search shows wrong query results

#### How I reproduced it

- I cann't reproduced this issue yet.

### RES-102 · Crash after leaving My orders

#### How I reproduced it

- Opened My orders with an order that has an upcoming pickup, then
  navigated back. Then the console showed `setState() called after dispose()`.

#### Root cause

- `PickupCountdown` starts a `Timer.periodic` in `initState()`,
  but the timer was never stored or cancelled. After the
  widget is disposed, the timer keeps firing and calls `setState()` on
  a State that no longer exists.
- lib/feature/order/widget/pickup_countdown.dart

#### Fix

- Store the timer in a field (`Timer? _timer`) and call
  `_timer?.cancel()` in `dispose()`, so the timer's lifetime matches
  the widget's lifetime.

### RES-103 · Requests pile up

#### How I reproduced it**

- Opened several deal pages, went back each time, then tapped "Add to bag".

#### Root cause

- `DealDetailsController` [register a worker on `cartService.itemCount`
  in `onInit()` — lib/feature/deal/deal_details_controller.dart:36], but the worker is never disposed.
  `CartService` lives for the whole app, so the workers of closed
  screens keep listening. Each cart change runs every old worker, and
  each one calls `GET /deals/:id` to get the deal quantity.
- /lib/feature/deal/deal_details_controller.dart

#### Fix

- Keep the `Worker` in a field and call `dispose()` in `onClose()`, so
  the listener's lifetime matches the controller's.
- Added `[quantityInCart]` to `CartService` to calculate the deal
  quantity locally.

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
