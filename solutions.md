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
| RES-105 Janky feed / memory growth | done | 07df0d0 |
| RES-106 Wrong pickup times | | |
| RES-107 Deep link crash | done | 6b91592 |
| F-1 Flash-sale countdowns | partial | 2c814c6 |
| F-2 Impression tracking | done | 2de2041 |
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

### RES-105 · Janky feed / memory growth

#### How I reproduced it**

- Keep scrolling to load more deal items

#### Root cause

- `HomeScreen.dart` on visible deal section it using map

#### Fix

- Refactor map statement into SliverBuilder

### RES-107 · Deep link opens to a crash

#### How I reproduced it

- Home → ⋮ → "Simulate deep link…" with
  `rescu://open/deal?id=42&source=push`. The app threw
  `type 'Null' is not a subtype of type 'DealModel'`.

#### Root cause

- `DealDetailsController.onInit` did `Get.arguments as DealModel`.
  From the feed and flash rail, the caller passes the whole
  `DealModel` as `arguments`. A deep link carries only a URL, so
  `Get.arguments` is `null` and the cast throws. The controller
  assumed that every caller already has the object.

#### Fix

- If `Get.arguments` is a `DealModel`, use it as before. Otherwise
  read `id` from `Get.parameters`, fetch the deal with
  `dealRepo.fetchById`, and show a loading state, then the page.
  `deal` became nullable (`Rxn<DealModel>`) and the screen handles
  loading, error (with a retry button) and loaded states.

---

## Part B: Features

### F-1 · Flash-sale countdowns

#### Status: partial. Done: live countdown on the flash rail
removal from the bag. Not done.

#### Approach

- `FlashDealCountdown` is a small `StatefulWidget` with its own
  `Timer.periodic`. Its `build` returns only a `Text`, so each
  per-second `setState` rebuilds that text and nothing else. It only
  calls `setState` when the formatted text changes.
- I extracted `FlashSaleCard` from the flash rail. When the countdown
  reaches zero it calls `onExpired`, and the card becomes a disabled
  "Expired" card.

#### Why this design

- Rebuilds are scoped to the countdown text, not to the card or the
  list.
- The remaining time is computed from `flashSaleEndsAt` on every tick,
  not by decrementing a counter, so it stays correct after a rebuild.
- The timer is cancelled in `dispose()` (same lesson as RES-102).

#### What I would do next

- Move expiry into `CartService` (its own timers) so it works without
  a mounted card, guard `CartService.add` against expired deals, and
  reuse `FlashDealCountdown` on the feed cards and the details screen.

### F-3 only: product decision on reservation expiry

- **What happens when a reservation expires while the user is in the app / mid-checkout:** ...
- **Why this is the right behaviour for users:** ...
- **Options I rejected and why:** ...

---

## Part C: AI usage log

### Tools used

- **Claude** and **Gemini** (chat only, no coding agents such as
  Claude Code, Cursor or Copilot). I used both in the same way:
  - to understand the brief, the git workflow and Conventional Commits;
  - to explain unfamiliar behaviour (e.g. GetX workers and lifecycle);
  - to generate drafts (e.g. [code suggestions, commit messages,
    solutions.md text]) and to check my own diagnosis and fixes;
  - to correct the English in my write-ups.
- I reviewed every suggestion against the code and the running app
  before using it, and I can explain each line I submitted.

### How I used AI

- **Understanding:** I asked Claude and Gemini to explain the
  assessment brief, the git workflow, Conventional Commits, and
  unfamiliar GetX behaviour such as workers and controller lifecycle.
- **Checking:** I wrote my own diagnosis first, then asked AI to check
  it, for example [RES-102: the timer not cancelled in dispose(),
  RES-103: the worker not disposed in onClose()].
- **Generating:** I used AI to generate code suggestions, commit
  message, solutions.md.

---

## Part C: Design questions

### Q1. `GetxController` lifecycle vs widget `State` lifecycle

*(Difference between the two. Name one Part A bug caused by confusing them.)*

<answer>

### Q2. When does one large `Obx` hurt?

*(How do I decide how tightly to scope reactivity?)*

It rebuilds the widgets that are wrapped in `Obx`. You should wrap only the widgets that actually change.

### Q3. How would I test for RES-106?

*(What test would have caught it, and what code changes would make it testable?)*

<answer>

---

## Time spent

| Item | Approx. time |
| --- | --- |
| Setup | 2hr. |
| RES-101 | 1h |
| RES-103 | 1h 30m |
| RES-107 | 30m |
| F-1 | 3h |
| F-2 | 30m |
| Writing this document | 2h 30m |
| **Total** | 11h 30m |

## What I would do next with one more day

- Complete the remaining tasks in priority order: F-1 and F-3 first, followed by RES-106, and then finish Part C.
