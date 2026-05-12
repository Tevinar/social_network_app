# Social App

A Flutter social application demo backed by a custom NestJS API.

## Overview

Social App is a client application built with Flutter. It currently covers
three main capabilities:

- email/password authentication
- blog publishing with image upload and cache-first reading
- chat and messaging with server-pushed SSE updates

The project is intended as a technical codebase organized around explicit
architectural boundaries. It is suitable for learning and evolving a
feature-based Flutter architecture with BLoC, dependency injection, local
cache, and a custom HTTP backend.

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

- HTTP client: `dio`
- Auth/session persistence: `flutter_secure_storage`
- Local structured cache: Drift / SQLite for blog persistence
- Local file cache: disk-backed cache for blog images
- Read strategy: cache-first `observe...` flows for initial blog list and blog
  viewer, one-shot `get...` pagination for additional slices
- Server push: SSE for chat list and per-chat message streams

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
expose safe results through `Either<Failure, T>`, one-shot `get...` reads,
cache-first `observe...` streams, or backend-driven `subscribe...` streams
depending on the use case.

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

Runtime configuration is provided through Dart defines. The main required value
is:

```sh
flutter run --dart-define=BACKEND_BASE_URL=http://localhost:3000
```

If omitted, the app defaults to `http://localhost:3000`.

When running the app on the Android emulator against a backend on your
development machine, you can keep `http://localhost:3000` by forwarding the
port with:

```sh
adb reverse tcp:3000 tcp:3000
```

The client expects the backend to expose:

- authentication
  - `POST /auth/sign-up`
  - `POST /auth/sign-in`
  - `POST /auth/refresh`
  - `POST /auth/sign-out`
- blogs
  - `POST /blogs`
  - `GET /blogs`
  - `GET /blogs/:blogId`
  - `GET /blogs/:blogId/image`
- chats
  - `POST /chats`
  - `GET /chats`
  - `GET /chats/candidates`
  - `GET /chats/by-members`
  - `GET /chats/:chatId/messages`
  - `POST /chats/:chatId/messages`
  - `SSE /chats/events`
  - `SSE /chats/:chatId/messages/events`

The blog feature uses local cache to make primitive-id navigation feel fast:

- list page: cached initial slice can render before remote refresh
- viewer page: `blogId` stays the route contract for deep links and push
  notifications, while cache-first observation recreates the fast-first-render
  behavior you would otherwise get by passing a full `Blog` object

### Run the Project

```bash
flutter run
```

Examples:

```bash
flutter run -d ios
flutter run -d android
flutter run --dart-define=BACKEND_BASE_URL=https://api.example.com
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
- integration tests
- automated coverage baseline

## Additional Documentation

- [architecture.md](./architecture.md)

## License

This repository is shared as a personal portfolio and demo project.

No open-source license is granted. All rights are reserved.

You may view the code for evaluation and learning purposes, but you may not copy, modify, distribute, or use any part of this project in your own work without prior written permission.
