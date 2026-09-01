# Responsive and Adaptive Lumen Streaming Dashboard

Lumen is an original single-screen Flutter streaming dashboard created to
demonstrate responsive layouts and platform-adaptive controls. Its featured
science-fiction drama, **Afterlight**, uses original cinematic artwork.

## Responsive behavior

The screen uses `LayoutBuilder` and the available width rather than a device
name:

- **Mobile (under 700 px, plus short landscape windows):** stacked, scrollable
  content and bottom navigation.
- **Tablet (700–1149 px):** compact navigation rail and wider content cards.
- **Desktop/web (1150 px and above):** compact sidebar and a two-column
  dashboard. Mouse cursors and tooltips make controls web-friendly.

## Adaptive behavior

- **iOS:** `CupertinoApp`, `CupertinoPageScaffold`, `CupertinoButton`,
  Cupertino icons, and `CupertinoTabBar`.
- **Android:** Material 3 app, buttons, icons, and `NavigationBar`.
- **Web/desktop:** Material controls with a persistent `NavigationRail`, an
  expanded rail on wide screens, and pointer-friendly interactions.

## Run the app

```bash
flutter pub get
flutter run
```

Choose an Android emulator, a connected Android device, or Chrome when Flutter
prompts for a target.

## Verify the project

```bash
flutter analyze
flutter test
```

## Artwork

The `Afterlight` hero artwork was generated specifically for this educational
project. Lumen and all titles shown in the interface are fictional.
