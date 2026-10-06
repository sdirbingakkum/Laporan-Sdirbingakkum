# Cloud build and deployment

The release path is cloud-only.

## Verification

GitHub Actions runs:

- Flutter dependency resolution
- Dart formatting check
- Flutter analyze
- Flutter tests
- Web release build
- Android release APK build
- Windows release build

## Web deployment

The main branch deploys Flutter Web to GitHub Pages.

GitHub Actions secret required:

- `SUPABASE_PUBLISHABLE_KEY`

The Supabase URL is non-secret and is fixed to the Puspomad project:

`https://ybepaqmrrgsaeqnqrsrf.supabase.co`

The publishable key is injected only at build time with `--dart-define`.
