# Numind iOS

SwiftUI app. iOS 17.0+, Swift 5.9+, no third-party dependencies in V1.

## Requirements

- Xcode 16+
- iOS 17.0+ simulator or device

## Project generation

The Xcode project is generated from `project.yml` using [xcodegen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen   # first time only
cd apps/ios
xcodegen generate
```

Regenerate whenever `project.yml` changes (e.g. after adding new source files or folders).

## Open in Xcode

```bash
open apps/ios/Numind.xcodeproj
```

## Build from terminal

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer \
xcodebuild \
  -project Numind.xcodeproj \
  -scheme Numind \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" \
  -configuration Debug \
  build \
  CODE_SIGNING_ALLOWED=NO
```

## Folder structure

```
Numind/
  App/                  # Entry point: NumindApp + RootView
  Core/
    DesignSystem/       # Tokens, primitives, theme
    Navigation/         # Tab bar and navigation shell
    Persistence/        # UserDefaults persistence layer
  Domain/
    Models/             # Codable data models
    QuizEngine/         # Template-driven question generation
    LessonEngine/       # Lesson state and progression
  Features/
    Home/               # Home / daily workout tab
    Learn/              # Module list and module detail
    Lesson/             # Lesson content screen
    Quiz/               # Quiz session, feedback, summary
    Progress/           # Progress tab
    Profile/            # Profile tab
  Resources/
    LocalContent/       # JSON fixtures (modules, lessons, templates)
```

## Key decisions (V1)

- Persistence: UserDefaults (SwiftData deferred until Supabase lands)
- Quiz format: MCQ-only
- No third-party SPM packages
- Calculators are a website feature, not in the iOS app
