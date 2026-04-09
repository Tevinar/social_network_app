# Social App

A Flutter social application demo connected to Supabase.

This project is designed with a structured architecture focused on
maintainability, scalability, and clear separation of responsibilities.

## Overview

Social App is a client application built with Flutter. It currently covers
three main capabilities:

- email/password authentication
- real-time blog publishing with image upload and offline-aware reading
- real-time chat and messaging

The project is intended as a technical codebase
organized around explicit architectural boundaries. It is suitable for learning
and evolving a feature-based Flutter architecture with BLoC, dependency
injection, and Supabase.

This project solves the need for a single codebase that combines:

- session-aware navigation
- feature isolation
- real-time updates
- local-first blog loading and disk-cached blog images
- backend integration through clear infrastructure boundaries

It is a mobile-first Flutter application, but the repository also includes the standard multi-platform Flutter targets.

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

### Data / Persistence

- Database: Supabase Postgres
- Query layer: `supabase_flutter` / Supabase client APIs and RPC calls
- Local structured cache: Drift / SQLite for blog persistence
- Local file cache: disk-backed cache for blog images
- Read strategy: cache-first streams for blog pages and blog viewer flows

### Infrastructure

- Hosting / Deployment: not automated in this repository; depends on the
  Flutter target platform
- CI: GitHub actions are defined for:
  - automatic package updates
  - code generation verification
  - formating
  - static analysis
  - run of unit and widget tests
  - test build validation
  - release build validation
  - SonarQube Analysis
- CD: not configured yet in the repository
- Monitoring / Observability: local logging through Talker; no remote
  monitoring sink configured yet

### Testing Tooling

- `flutter_test`
- `bloc_test`
- `mocktail`

## Architecture Summary

The project uses a feature-based structure with three top-level responsibility
zones:

- `core/` for passive shared technical building blocks
- `app/` for application-wide orchestration
- `features/` for business capabilities split into `data`, `domain`, and
  `presentation`

At runtime, feature UI is coordinated with BLoC/Cubit, navigation is handled
through `GoRouter`, dependencies are composed with `GetIt`, and repositories
expose safe results through `Either<Failure, T>` or cache-first stream
snapshots when stale local data can be shown before remote refresh completes.

For the full architectural rules, dependency direction, testing conventions,
and runtime coordination patterns, see [architecture.md](./architecture.md).

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

## Testing and Quality

- Unit tests
- Widget tests for targeted UI behavior
- Current automated coverage baseline: 100% line coverage across the project

## Getting Started

### Prerequisites

You need:

- Flutter SDK compatible with `sdk: ^3.10.4`
- a working Flutter toolchain for your target platform

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
5. merge after workflows validation

Suggested conventions:

- prefer focused branches such as `fix/...`, `chore/...`, `feat/...`
- prefer clear, focused commits
- prefer merge requests that solve one coherent problem at a time

## Releases and Versioning

The app version is currently managed through `pubspec.yaml`.

There is no documented release workflow yet in the repository. Until one is introduced, version updates should remain explicit and intentional.

## Roadmap

Possible future improvements include:

- CD automation
- remote error monitoring / crash reporting

## Additional Documentation

- [architecture.md](./architecture.md)

## License

This repository is shared as a personal portfolio and demo project.

No open-source license is granted. All rights are reserved.

You may view the code for evaluation and learning purposes, but you may not copy, modify, distribute, or use any part of this project in your own work without prior written permission.
