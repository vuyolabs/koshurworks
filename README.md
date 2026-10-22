# KoshurWorks — UI prototype

KoshurWorks is a local work-discovery and skilled-trades marketplace, starting in Jammu & Kashmir.
This repository currently contains a **frontend-only Flutter prototype**. There is no backend,
authentication, database, payments, maps or messaging. All people, listings and ratings are sample data.

## Run

```sh
flutter pub get
flutter run            # on an Android device or emulator
flutter test           # unit and widget tests
flutter analyze
```

## Structure

```
lib/
  main.dart                 Entry point
  app/                      App root, in-memory AppState, central router
  core/
    theme/                  Colour, spacing, radius, motion and type tokens; Material 3 theme
    widgets/                Reusable UI: buttons, cards, chips, badges, sheets, filter sheet, motion
    utils/                  Formatters (rupees, dates, initials)
  data/
    models/                 Immutable typed models (WorkListing, WorkerProfile, WorkCategory)
    mock/                   Sample listings, workers, categories and districts
    repositories/           Repository interfaces + mock implementations
  features/
    onboarding/             Welcome screen and illustration
    shell/                  Bottom navigation with prominent Post Work action
    home/                   Dashboard (adapts to worker or hirer mode)
    work_discovery/         Find Work: search, category chips, filters, sort
    work_details/           Listing detail with interest and contact actions
    post_work/              Multi-section form with validation, preview and success state
    worker_discovery/       Find Workers
    worker_profile/         Worker profile and own editable profile
    saved_work/             Saved listings
    account/                Account, role switch, preferences, help and about
    common/                 Shared prototype contact sheet
```

## Swapping in real services later

- Screens read data through `WorkRepository` and `WorkerRepository`. Replace the mock
  implementations passed to `KoshurWorksApp` with HTTP-backed ones.
- `AppState` is a single `ChangeNotifier` exposed through `AppScope`. Split it per feature, or move to
  another state solution, when real business logic arrives.
- Colours live in `core/theme/app_colors.dart`. The logo placeholder is `BrandMark` in
  `core/widgets/brand_mark.dart`; replace its body with the approved logo asset.
