# NotifyTrade 📣📈

A simple, attractive Flutter demo application for market alerts across Android and iOS.

## Included

- NotifyTrade branding and launcher icon
- Separate market sections for **NIFTY, BANK NIFTY, SENSEX, FINNIFTY, and MIDCAP NIFTY**
- Market snapshot and simple intraday chart
- BUY / WAIT demo alerts grouped by index
- Alert detail sheet and watchlist action
- Notification toggle and dark mode
- Android and iOS GitHub Actions builds

## Build locally

```bash
flutter pub get
dart run flutter_launcher_icons
flutter run
```

## GitHub Actions

Push the extracted project to the `main` branch. The workflow under `.github/workflows/build.yml` builds an Android release APK and an unsigned iOS release artifact.

> The market values and alerts are demo data only. This project does not connect to a broker or execute trades.
