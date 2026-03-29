# Architecture

This document describes the architectural structure of the project, the main
design principles, and the practical rules used to keep the codebase
maintainable and scalable.

## 1. Purpose

This architecture was chosen to organize the project around three clear
responsibility zones:

- `core/` for passive, reusable technical building blocks
- `app/` for application-level orchestration
- `features/` for business capabilities

The goals are:

- scalability as features grow
- readability through explicit structure
- separation of responsibilities
- maintainability over time
- ease of evolution without widespread coupling

This structure is intended to make it easy to answer a practical question for
any file: is this a low-level tool, an app-wide coordinator, or part of a
business capability?

---

## 2. Architectural Principles

The project follows these principles:

- separation of concerns
- explicit boundaries
- low coupling between business capabilities
- dependency inversion where it improves clarity
- modularity by feature
- predictability in data flow
- passive shared foundations
- pragmatic consistency over dogmatism

In this interpretation of the architecture:

- `core/` should stay passive and feature-agnostic
- `app/` should orchestrate global behavior without owning feature business
  logic
- `features/` should own business behavior and remain as self-contained as
  reasonably possible

---

## 3. High-Level Overview

At a high level, the project is organized like this:

- the interface layer lives mainly in `features/*/presentation` and renders UI
  while coordinating state through BLoC/Cubit
- the domain layer lives in `features/*/domain` and contains entities, use
  cases, and repository contracts
- the infrastructure layer lives in `features/*/data` and implements those
  contracts through Supabase and other technical services
- the shared low-level foundation lives in `core/`
- the application-wide coordination layer lives in `app/` and sits alongside
  feature modules rather than between every feature layer

In short:

- `core` = tools
- `app` = orchestration
- `features` = business capabilities

---

## 4. Project Structure

The project is structured as follows:

```text
lib/
 ├── core/
 ├── app/
 ├── features/
```

Feature modules are further organized like this:

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

The intent of this structure is:

- `core/` contains passive, reusable technical code
- `app/` contains global application coordination
- `features/` contains business behavior grouped by capability

This is not a strict academic layering exercise. It is a practical structure
used to keep the codebase understandable as it grows.

---

## 5. Layer Responsibilities

### `core/`

Responsibility:

- provide low-level, feature-agnostic building blocks

Contains:

- shared error abstractions
- shared constants and schema names
- configuration access
- low-level network abstractions
- use case conventions
- reusable utilities
- feature-agnostic shared widgets
- technical service abstractions

Must not contain:

- app flows
- BLoCs / Cubits
- feature use cases
- business concepts such as `User`, `Blog`, or `Chat`
- navigation or orchestration logic

Important rule:

- code in `core/` should still make sense if all features were removed

### `app/`

Responsibility:

- orchestrate global application behavior

Contains:

- bootstrap and startup coordination
- dependency injection wiring
- routing and route guards
- app shell
- global session state
- app-level logging integration
- concrete implementations of shared technical services when they are app-wide

Must not contain:

- feature-specific business logic
- feature persistence details
- domain rules belonging to one business capability

Important rule:

- `app/` coordinates features, but does not become a new business layer

### `features/*/domain/`

Responsibility:

- own the business-facing behavior of a feature

Contains:

- entities
- value objects when needed
- use cases
- repository interfaces

Must not contain:

- framework-specific UI logic
- transport models
- external system implementation details

### `features/*/data/`

Responsibility:

- implement infrastructure details for a feature

Contains:

- repository implementations
- data sources
- DTOs / transport models
- external persistence integration

Must not contain:

- UI logic
- navigation behavior
- feature presentation state

### `features/*/presentation/`

Responsibility:

- render UI and coordinate feature-scoped state

Contains:

- pages
- widgets
- BLoCs / Cubits
- events and states

Must not contain:

- direct persistence logic
- external API handling
- low-level infrastructure details

---

## 6. Dependency Rules

The main dependency rules are:

- `core/` must not depend on `app/` or `features/`
- `app/` may depend on stable abstractions and coordinate features
- `features/*/presentation` may depend on feature domain and selected app-level
  coordinators
- `features/*/domain` must not depend on `features/*/data`
- `features/*/data` implements domain contracts
- feature presentation should not depend on other feature presentation layers
- feature data should not depend on presentation

Practical reading of the dependency direction:

```text
Feature UI
↓
Feature Domain
↓
Feature Data
```

`app/` is not a mandatory middle layer for every feature flow. It exists for
global coordination concerns such as bootstrap, routing, lifecycle, and session
state.

This is a rule of responsibility and ownership more than a rigid import graph.

Shared code is allowed only when ownership is explicit and justified.

---

## 7. Application Flow

A typical command flow is:

1. a user interacts with a page or widget
2. a BLoC/Cubit in `presentation/` receives the intent
3. the BLoC invokes a use case from `domain/`
4. the use case delegates to a repository contract
5. the repository implementation in `data/` performs the technical work
6. results are mapped back to domain entities or failures
7. the BLoC emits a new UI state

A typical reactive flow is:

1. a repository exposes a passive stream of domain-level changes
2. a BLoC subscribes to that stream
3. stream emissions are converted into BLoC events
4. state is updated through the BLoC event pipeline

An app-wide coordination flow looks different:

1. startup or session state changes occur
2. `app/` modules coordinate routing, bootstrap, or global session behavior
3. features react to the resulting app-level state when needed

This keeps business actions inside features while reserving `app/` for global
coordination concerns such as startup, navigation, and session handling.

---

## 8. Error Handling Strategy

Errors are represented and propagated according to their level:

- infrastructure and external integrations may produce technical exceptions
- repositories map those exceptions into safe `Failure` objects
- use cases and presentation layers consume `Either<Failure, T>`
- UI receives intentional, user-safe messages
- logs may keep richer technical details than user-facing states

Practical rules:

- technical exceptions should not leak directly to the UI
- unexpected failures should be logged with stack traces
- expected business-safe failures should be modeled explicitly
- global handlers exist as a last-resort safety net, not as a replacement for
  local responsibility

This keeps the application behavior explicit while preserving observability.

---

## 9. Shared Services and Cross-Cutting Concerns

The project shares some concerns across modules:

- logging
- configuration and environment access
- connectivity checking
- image picking abstraction
- shared formatting and technical utilities
- common theme and small UI primitives

Rules for deciding where shared code belongs:

- put passive, feature-agnostic technical code in `core/`
- put app-wide coordination concerns in `app/`
- do not move feature logic into shared modules just to reduce duplication
- do not turn `core/` into a dumping ground

An external dependency is acceptable in `core/` only when it supports an
architectural convention, not when it introduces app-specific behavior.

---

## 10. Testing Strategy

The testing strategy should prioritize behavior over surface area.

Recommended focus:

- unit tests for use cases, repositories, mappers, and BLoCs/Cubits
- focused widget tests for critical screens and interactions
- integration tests where boundaries with external systems matter

Practical rules:

- test business behavior inside features first
- mock data sources when testing repositories
- mock repositories or use cases when testing BLoCs/Cubits
- keep passive helpers and mappers easy to test in isolation
- low-signal bootstrap or declarative configuration code does not need the same
  testing priority as business behavior

The goal is not to maximize coverage mechanically. The goal is to test the code
that owns decisions and behavior.

---

## 11. Conventions and Practical Rules

The following conventions make the architecture usable in daily work:

- DTOs / transport models live in `data/models`
- external system access lives in `data/data_sources`
- repository implementations live in `data/repositories`
- business-facing use cases live in `domain/usecases`
- shared low-level abstractions belong in `core/`
- app-wide coordination belongs in `app/`
- feature UI state belongs in `presentation/`

Additional rules:

- mapping logic should live in models, repositories, or dedicated mappers, not
  in the UI
- feature BLoCs should coordinate feature behavior, not low-level technical
  details
- app-level state should exist only when the concern is truly global
- structure should grow only when needed
- not every operation needs a new abstraction if it adds no real clarity

Sharing rules:

- domain entities may be shared only with clear ownership and intention
- feature UI, feature BLoCs, and DTOs should not be shared arbitrarily

---

## 12. Runtime and Coordination Patterns

Because this is a Flutter client application, runtime coordination is centered
on:

- BLoC/Cubit for state management
- `GoRouter` for navigation
- `GetIt` for dependency composition
- async repository calls for commands and queries
- passive streams for realtime backend-driven updates

Important patterns in this project:

- app-wide session state is coordinated in `app/session`
- feature state is coordinated inside feature presentation modules
- some states are global, while others are page-scoped when isolation matters
- startup is coordinated in `app/bootstrap`
- navigation is coordinated in `app/router`

This keeps runtime orchestration visible and explicit instead of spreading it
across unrelated modules.

---

## 13. Trade-offs and Practical Decisions

This architecture is intentionally pragmatic.

Important trade-offs:

- not every operation needs its own abstraction
- use cases are kept when they improve consistency and ownership, not only for
  academic purity
- `core/` stays intentionally limited
- `app/` is an orchestration layer, not a hidden business layer
- some cross-feature sharing is tolerated when ownership is explicit and the
  concept is genuinely shared
- clarity is preferred over unnecessary indirection

The guiding rule is:

- `core` stays passive
- `app` orchestrates globally
- `features` own business behavior

Consistency is preferred, but pragmatism is allowed when justified.

---
