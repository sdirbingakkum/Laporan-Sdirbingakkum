# Architecture

## Goal

One Flutter codebase optimized for mobile, while remaining responsive for Web and Windows desktop.

## Layers

presentation
↓
application/state
↓
domain
↑
data/infrastructure
↓
Supabase

For the bootstrap, only the layers needed by the current vertical slice are created. Domain and repository abstractions are introduced when the first real feature needs them.

## Rules

1. Widgets do not call Supabase directly.
2. Supabase SDK usage stays in bootstrap/data infrastructure.
3. Domain models must not depend on Flutter or Supabase.
4. Riverpod is the only state-management framework.
5. go_router handles app navigation and Web deep links.
6. Responsive layout is adaptive, not duplicated per platform.
7. Client builds only receive the publishable Supabase key.
8. No service-role or secret key is ever shipped to Flutter.
9. Supabase schema changes are outside this repository unless explicitly requested.

## Platform strategy

- Android: primary UX target.
- Web: responsive application and deployment target.
- Windows: desktop target using the same feature code.
- macOS/Linux can be added later without changing the architecture.

## Dependency strategy

Keep the dependency graph small. Prefer Flutter SDK capabilities first; add a package only when it solves a recurring product-level problem.
