# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StreamPlayerApp is a Netflix-like streaming app built as an educational KMP (Kotlin Multiplatform Mobile) project by the CodandoTV community. It targets Android and iOS from a shared codebase.

## Build Commands

```bash
# Android
./gradlew :composeApp:assembleDebug
./gradlew :composeApp:assembleRelease

# Unit tests (all modules)
./gradlew testDebugUnitTest

# Run a single test class
./gradlew test --tests "feature_detail.DetailStreamViewModelTest"

# iOS simulator tests
./gradlew iosSimulatorArm64Test

# Linting (detekt)
./gradlew detekt
./gradlew :feature-detail:detekt   # single module

# Coverage report (min 80% required)
./gradlew :composeApp:koverHtmlReportDebug
```

## Architecture

Clean Architecture + MVVM, organized into feature and core modules:

```
composeApp (entry points: Android Application, iOS MainViewController)
├── feature-list-streams   — home feed with genre sections and top-rated banner
├── feature-detail         — movie detail + video streams
├── feature-search         — search + most-popular paging
├── feature-profile        — Netflix-style profile picker
└── feature-news           — news feed with camera/gallery/permission integration

core-networking            — Ktor HttpClient, Bearer auth, failure handling
core-local-storage         — Room database (KMP)
core-navigation            — sealed-class routes, NavHost setup
core-shared-ui             — Material3 theme, shared Compose components
core-shared                — common utilities
core-permission            — MOKO permissions wrapper
core-camera-gallery        — androidx.camera integration
core-background-work       — WorkManager tasks + KMPNotifier notifications
build-logic/               — custom Gradle convention plugins
```

**Data flow per feature:**
`Compose Screen → ViewModel (StateFlow) → UseCase → Repository → Service (Ktor) → TMDB API`

Each feature follows the same layering: `*Screen.kt` → `*ViewModel.kt` → `*UseCase.kt` → `*Repository.kt` → `*Service.kt`.

## Key Technology Choices

| Concern | Library |
|---|---|
| DI | Koin 4.x (`koin-compose-viewmodel`) |
| HTTP | Ktor 3.x + OkHttp (Android) / Darwin (iOS) |
| DB | Room 2.7 (KMP) + SQLite Bundled |
| Navigation | Navigation Compose 2.7 |
| Pagination | Paging Compose 3.3 |
| Images | Coil 3 + `coil-network-ktor3` |
| Animations | Lottie 5.2 |
| Testing | JUnit4, MockK, Kotlinx Coroutines Test |
| Coverage | Kover (80% minimum) |
| Lint | Detekt 1.23.6 (`config/detekt/detekt.yml`) |

## Multiplatform Conventions

- Shared logic lives in `commonMain`; platform overrides use `androidMain` / `iosMain`
- Platform-specific files are named `*.android.kt` / `*.ios.kt`
- Tests go in `commonTest` for KMP compatibility
- Dependency versions are centralized in `gradle/libs.versions.toml`
- JVM target: Java 17 | Min SDK: 28 | Target/Compile SDK: 35

## API & Configuration

- Primary API: TMDB (`https://api.themoviedb.org/3/`) — Bearer token auth
- Profile API: `https://demo3364084.mockable.io/` (mock)
- App ID: `com.codandotv.streamplayerapp`

## Testing Patterns

Feature modules ship `Fake*` implementations (e.g., `FakeDetailStreamUseCase`, `FakeVideoStreamsUseCase`) for use in ViewModel tests instead of mocking. Use these fakes when writing new tests rather than adding more MockK stubs for domain-layer dependencies.
