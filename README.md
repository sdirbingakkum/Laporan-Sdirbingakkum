# Laporan Sdirbingakkum

Flutter application for the Laporan Sdirbingakkum system.

## Platform targets

- Android — primary
- Web — responsive and deployable
- Windows — desktop-ready

The product uses one Flutter codebase. Platform-specific behavior is isolated so future macOS/Linux support can be added without a second application.

## Architecture

The foundation is intentionally pragmatic and lightweight:

```
Presentation
    ↓
Application / State
    ↓
Domain contracts
    ↑
Data / Infrastructure
    ↓
Supabase
```

Current bootstrap uses:

- Flutter Material 3
- Riverpod for state
- go_router for navigation and web deep links
- supabase_flutter for backend access

UI widgets never issue Supabase queries directly. Supabase integration remains outside presentation code.

## Backend

Supabase project:

`https://ybepaqmrrgsaeqnqrsrf.supabase.co`

The Supabase schema is maintained separately and must be treated as an external database contract.

Client builds use only the Supabase publishable key. Never place a service-role or secret key in Flutter source, assets, Git history, or deployment artifacts.

## Configuration

The Supabase URL is the Puspomad project above.

The publishable key is injected at build time:

```text
--dart-define=SUPABASE_PUBLISHABLE_KEY=...
```

Production CI reads it from the GitHub Actions secret:

`SUPABASE_PUBLISHABLE_KEY`

## Cloud-first delivery

The repository contains GitHub Actions workflows for:

- generating Android/Web/Windows Flutter runners
- formatting
- static analysis
- unit/widget tests
- Web release build
- Android release APK build
- Windows desktop release build
- GitHub Pages Web deployment

The release path does not require a developer machine.

## Repository rules

1. Keep dependencies small.
2. Prefer Flutter SDK capabilities before adding packages.
3. Keep business logic out of widgets.
4. Keep database concerns out of presentation.
5. Never ship Supabase service-role credentials.
6. Do not modify Supabase schema from this application repository unless explicitly required.

<!-- production-deploy: 2026-10-09 / PR #1 merged -->
