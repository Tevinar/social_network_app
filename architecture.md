# Architecture

This document defines the project structure, the responsibilities of each
module, and the practical rules used to keep the codebase maintainable as it
grows.

## 1. Goals

The architecture is designed to provide:

- clear ownership of code
- explicit boundaries between business logic, app orchestration, and shared
  technical code
- low coupling between features
- predictable data flow
- scalability without widespread rewrites

The core organizing question for any file is:

- is it a passive shared building block?
- is it app-wide coordination?
- is it part of a business capability?

---

## 2. Project Structure

```text
lib/
 ├── core/
 ├── app/
 └── features/
```

Feature modules follow the same internal structure:

```text
features/
 ├── auth/
 │    ├── data/
 │    ├── domain/
 │    └── presentation/
 ├── blog/
 │    ├── data/
 │    ├── domain/
 │    └── presentation/
 └── chat/
      ├── data/
      ├── domain/
      └── presentation/
```

This is a practical structure for clarity and growth, not an academic layering
exercise.

---

## 3. Responsibilities by Module

### `core/`

Purpose:

- passive, feature-agnostic technical building blocks

Typical contents:

- shared errors and low-level abstractions
- configuration access
- shared constants and schema names
- reusable utilities
- use case conventions
- feature-agnostic widgets
- technical service abstractions

Must not contain:

- business concepts such as `User`, `Blog`, or `Chat`
- feature use cases
- app flows, navigation, or orchestration logic
- BLoCs or Cubits

Rule:

- code in `core/` should still make sense if all features were removed

### `app/`

Purpose:

- application-wide orchestration

Typical contents:

- bootstrap and startup coordination
- dependency injection wiring
- routing and route guards
- app shell
- global session state
- app-wide logging integration
- concrete shared service implementations when they are truly global

Must not contain:

- feature-specific business logic
- feature persistence details
- domain rules owned by a single feature

Rule:

- `app/` coordinates features, but is not a business layer

### `features/*/domain/`

Purpose:

- business-facing logic and contracts for a feature

Typical contents:

- entities
- value objects when needed
- use cases
- repository interfaces

Must not contain:

- transport models
- UI logic
- external system implementations

### `features/*/data/`

Purpose:

- infrastructure details and external integration for a feature

Typical contents:

- repository implementations
- data sources
- DTOs and models
- external persistence and API integration

Must not contain:

- UI logic
- navigation behavior
- feature presentation state

### `features/*/presentation/`

Purpose:

- UI rendering and feature-scoped state coordination

Typical contents:

- pages
- widgets
- BLoCs and Cubits
- events and states

Must not contain:

- direct persistence logic
- low-level infrastructure details
- external API handling

---

## 4. Dependency Rules

The default direction of responsibility is:

```text
Presentation
↓
Domain
↓
Data
```

Practical dependency rules:

- `core/` must not depend on `app/` or `features/`
- `app/` may coordinate features and depend on stable abstractions
- `features/*/presentation` may depend on feature domain and selected app-level
  coordinators
- `features/*/domain` must not depend on `features/*/data`
- `features/*/data` implements domain contracts
- feature presentation must not depend on other feature presentation layers
- feature data must not depend on presentation

Notes:

- `app/` is not a mandatory middle layer for every feature flow
- shared code is allowed only when ownership is explicit and justified

---

## 5. Runtime and Data Flow

### Command flow

1. a user interacts with a page or widget
2. a BLoC or Cubit in `presentation/` receives the intent
3. it invokes a use case from `domain/`
4. the use case delegates to a repository contract
5. the repository implementation in `data/` performs the technical work
6. results are mapped back to domain entities or failures
7. the BLoC emits a new UI state

### Reactive flow

1. a repository exposes a passive stream of domain-level changes
2. a use case exposes that stream to presentation
3. a BLoC subscribes to the stream
4. stream emissions are converted into BLoC events
5. state changes still go through the BLoC event pipeline

### App-wide coordination

Some runtime concerns are global rather than feature-local. In this project,
they are centered on:

- `app/bootstrap` for startup
- `app/router` for navigation
- `app/session` for global session state
- `GetIt` for dependency composition
- `GoRouter` for navigation
- BLoC/Cubit for state management

Rule:

- feature behavior stays inside features
- global lifecycle, routing, and session concerns live in `app/`

---

## 6. Error Handling

Errors are handled according to their level:

- infrastructure code may throw technical exceptions
- repositories map those exceptions into safe `Failure` objects
- use cases and presentation consume `Either<Failure, T>`
- UI receives intentional, user-safe messages
- logs may keep richer technical details than UI state

Practical rules:

- technical exceptions must not leak directly to the UI
- expected failures should be modeled explicitly
- unexpected failures should be logged with stack traces
- global handlers are a safety net, not a replacement for local handling

---

## 7. Shared Code and Cross-Cutting Concerns

Shared concerns in this project include:

- logging
- configuration and environment access
- connectivity checking
- image picking abstraction
- formatting and technical utilities
- theme and small UI primitives

Placement rules:

- passive, feature-agnostic technical code belongs in `core/`
- app-wide coordination belongs in `app/`
- feature logic must stay in features, even if duplication exists
- `core/` must not become a dumping ground

An external dependency belongs in `core/` only when it supports an
architectural convention rather than app-specific behavior.

---

## 8. Testing Strategy

Testing should prioritize behavior over surface area.

Recommended focus:

- unit tests for use cases, repositories, mappers, and BLoCs/Cubits
- focused widget tests for critical screens and interactions
- integration tests where external boundaries matter

Practical rules:

- test business behavior inside features first
- mock data sources when testing repositories
- mock repositories or use cases when testing BLoCs/Cubits
- keep helpers and mappers easy to test in isolation
- low-signal bootstrap or declarative wiring does not need the same testing
  priority as behavior-owning code

The goal is not mechanical coverage. The goal is to test code that owns
decisions and behavior. The current project baseline is high, but the lasting
expectation is to preserve disciplined behavior-focused coverage and maintain at
least a 70% overall baseline over time.

---

## 9. Practical Conventions

Default placement rules:

- DTOs and transport models live in `data/models`
- external system access lives in `data/data_sources`
- repository implementations live in `data/repositories`
- use cases live in `domain/usecases`
- feature UI state lives in `presentation/`

Additional conventions:

- mapping logic belongs in models, repositories, or dedicated mappers, not in
  the UI
- feature BLoCs coordinate behavior, not low-level technical details
- app-level state should exist only when the concern is truly global
- new abstractions should be introduced only when they add real clarity

Sharing rules:

- domain entities may be shared only with clear ownership
- feature UI, feature BLoCs, and DTOs should not be shared arbitrarily

---

## 10. Trade-offs

This architecture is intentionally pragmatic.

Guiding rules:

- `core/` stays passive
- `app/` orchestrates globally
- `features/` own business behavior

Practical trade-offs:

- not every operation needs its own abstraction
- use cases are kept when they improve clarity, consistency, or ownership
- `app/` must not become a hidden business layer
- some cross-feature sharing is acceptable when the concept is genuinely shared
  and ownership is explicit
- clarity is preferred over unnecessary indirection

Consistency matters, but pragmatism is allowed when justified.
