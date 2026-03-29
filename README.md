# Social App

A Flutter social application demo connected to Supabase.

This project is designed with a structured architecture focused on
maintainability, scalability, and clear separation of responsibilities.

## Overview

Social App is a client application built with Flutter. It currently covers
three main capabilities:

- email/password authentication
- blog publishing with image upload
- real-time chat and messaging

The project is intended as a technical codebase
organized around explicit architectural boundaries. It is suitable for learning
and evolving a feature-based Flutter architecture with BLoC, dependency
injection, and Supabase.

This project solves the need for a single codebase that combines:

- session-aware navigation
- feature isolation
- real-time updates
- backend integration through clear infrastructure boundaries

It is a mobile-first Flutter application, but the repository also includes the
standard multi-platform Flutter targets.

## Goals

The main goals of the project are:

- maintainability
- scalability
- readability
- explicit boundaries
- clear ownership of responsibilities
- ease of testing
- ease of evolution over time

## Tech Stack

### Core Technologies

- Language: Dart
- Framework: Flutter
- Runtime: Flutter client runtime on supported platforms

### Data / Persistence

- Database: Supabase Postgres
- Query layer: `supabase_flutter` / Supabase client APIs and RPC calls
- Cache: no dedicated caching layer yet

### Infrastructure

- Hosting / Deployment: not automated in this repository; depends on the
  Flutter target platform
- CI/CD: not configured yet in the repository
- Monitoring / Observability: local logging through Talker; no remote
  monitoring sink configured yet

### Testing

- Unit testing: `flutter_test`, `bloc_test`, `mocktail`
- Integration testing: limited / not formally structured yet
- End-to-end testing: not configured yet

## Architecture

The project follows a feature-based structure with three top-level
responsibility zones:

- `core/` for passive shared technical building blocks
- `app/` for application-wide orchestration
- `features/` for business capabilities

See [architecture.md](./architecture.md) for the complete architectural guide.

## Project Structure

```text
project-root/
  lib/
    app/
    core/
    features/
  assets/
  test/
  android/
  ios/
  web/
  macos/
  linux/
  windows/
```

Main folders:

- `lib/` contains the application source code
- `assets/` contains static assets and public environment config
- `test/` contains automated tests
- platform folders contain the standard Flutter targets

## Key Architectural Rules

The most important architectural rules are:

- `core/` stays passive and feature-agnostic
- `app/` coordinates global behavior without becoming a business layer
- `features/` own business behavior
- DTOs / transport models stay in feature `data/`
- shared modules should remain small and intentional

See [architecture.md](./architecture.md) for the detailed dependency and
sharing rules.

## Main Application Flow

The main feature flow is:

1. a user interacts with a page or widget
2. a BLoC/Cubit in `presentation/` receives the intent
3. the BLoC invokes a use case from `domain/`
4. the use case delegates to a repository contract
5. the repository implementation in `data/` performs the technical work
6. data is mapped back into domain entities or failures
7. the BLoC emits a new UI state

Global coordination such as startup, routing, and session handling lives in
`app/`.

## Error Handling

The error handling strategy is layered:

- technical errors originate in infrastructure
- repositories map them into `Failure` objects
- presentation consumes safe results through `Either<Failure, T>`
- global handlers act as a safety net for uncaught runtime errors

## Shared Services

Main shared and cross-cutting concerns include:

- logging
- configuration and environment access
- connectivity checking
- image picking abstraction
- date / text formatting helpers
- shared theme and UI primitives
- ID generation

## Testing Strategy

### Test Levels

- Unit tests
- Integration tests where useful
- Widget tests for targeted UI behavior
- No end-to-end suite configured yet

### Testing Principles

- isolated logic should be tested with unit tests
- repositories should be tested behind mocked data sources
- BLoCs/Cubits should be tested behind mocked repositories or use cases
- boundaries with external systems should be tested intentionally
- coverage should focus on meaningful behavior, not just declarative wiring

## Getting Started

### Prerequisites

You need:

- Flutter SDK compatible with `sdk: ^3.10.4`
- a working Flutter toolchain for your target platform
- a Supabase project configured with the expected resources

### Installation

```bash
git clone <repository-url>
cd social_app
flutter pub get
```

### Configuration

The repository includes `assets/config/env.public` for zero-config onboarding.

For local overrides, create a `.env` file at the root of the project:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Then run the app with:

```bash
flutter run --dart-define-from-file=.env
```

Supabase is expected to provide:

- email/password authentication
- a public `blog_images` storage bucket
- the tables used by the project (`profiles`, `blogs`, `chats`,
  `chat_members`, `chat_messages`)
- the RPC functions:
  - `create_chat_with_members`
  - `get_chat_by_members`
- realtime enabled for:
  - `blogs`
  - `chats`
  - `chat_messages`

### Run the Project

```bash
flutter run
```

Examples:

```bash
flutter run -d chrome
flutter run -d ios
flutter run -d android
flutter run --dart-define-from-file=.env
```

### Run Tests

```bash
flutter test
```

To generate coverage:

```bash
flutter test --coverage
```

### Run Lint / Static Analysis

```bash
flutter analyze
```

### Format Code

```bash
dart format .
```

## Development Workflow

Recommended workflow:

1. create a branch from the base branch
2. keep changes focused by topic
3. run tests and analysis locally
4. open a merge request / pull request
5. request review
6. merge after validation

Suggested conventions:

- prefer focused branches such as `fix/...`, `chore/...`, `feat/...`
- prefer clear, focused commits
- prefer merge requests that solve one coherent problem at a time

## Conventions

Practical conventions used in the project:

- feature modules are organized into `data`, `domain`, and `presentation`
- transport models live in `data/models`
- external integration code lives behind explicit feature boundaries
- app-wide coordination belongs in `app/`
- passive shared technical code belongs in `core/`

For the full architectural conventions, see [architecture.md](./architecture.md).

## Runtime and Coordination Patterns

The project relies on the following runtime patterns:

- BLoC/Cubit for state management
- `GoRouter` for navigation
- `GetIt` for dependency composition
- async repository calls for commands and queries
- passive streams for real-time backend-driven updates

Runtime coordination is split between feature-scoped BLoC/Cubit state and
app-level coordination for session, startup, and routing.

## Releases and Versioning

The app version is currently managed through `pubspec.yaml`.

There is no documented release workflow yet in the repository. Until one is
introduced, version updates should remain explicit and intentional.

## Roadmap

Possible future improvements include:

- stronger CI/CD automation
- remote error monitoring / crash reporting
- broader test coverage on key flows
- additional feature growth on top of the current auth, blog, and chat modules

## Contributing

Contributors should:

- keep changes focused
- respect the `core / app / features` architecture
- avoid introducing arbitrary cross-feature dependencies
- run tests and checks before submitting changes
- preserve explicit boundaries between presentation, domain, and data

For major changes, align on the architectural direction before expanding shared
modules or changing responsibility boundaries.

## Additional Documentation

- [architecture.md](./architecture.md)

## License

No license is specified yet in this repository.
