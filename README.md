# SOEN 390

| Branch  | Status                                                                                                                                                                       |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| main    | [![CI](https://github.com/SOEN-390-W2025/SOEN-390/actions/workflows/ci.yaml/badge.svg)](https://github.com/SOEN-390-W2025/SOEN-390/actions/workflows/ci.yaml)                |
| develop | [![CI](https://github.com/SOEN-390-W2025/SOEN-390/actions/workflows/ci.yaml/badge.svg?branch=develop)](https://github.com/SOEN-390-W2025/SOEN-390/actions/workflows/ci.yaml) |

[![codecov](https://codecov.io/github/NathanGrenier/SOEN-390/graph/badge.svg?token=QWLVNVQUYB)](https://codecov.io/github/NathanGrenier/SOEN-390)

[![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=SOEN-390-W2025_SOEN-390)](https://sonarcloud.io/summary/new_code?id=SOEN-390-W2025_SOEN-390)

# About

## Team Members

| Name               | Student ID | Email                      |
| ------------------ | ---------- | -------------------------- |
| Nathan Grenier     | 40250986   | nathangrenier01@gmail.com  |
| Sumer Abd Alla     | 40247712   | sendingtosumer@gmail.com   |
| David Carciente    | 40247907   | davidcarciente@outlook.com |
| Giuliano Verdone   | 40252190   | giulianoverdone@gmail.com  |
| Nirav Patel        | 40248940   | niravp0703@gmail.com       |
| Nathanial Hwong    | 40243583   | nathanial.hwong8@gmail.com |
| Brian Tkatch       | 40191139   | brian@briantkatch.com      |
| Jutipong Puntuleng | 40080233   | p.jutipong13@gmail.com     |
| Rym Bensalem       | 40237684   | rymbensalem816@gmail.com   |

# Getting Started

## Useful Flutter Commands

| Command             | `rps` Equivalent    | Description                                                                                       |
| ------------------- | ------------------- | ------------------------------------------------------------------------------------------------- |
| `flutter get`       | `rps get`           | Install the Project's Dependencies                                                                |
| `flutter analyze`   | `rps lint check`    | Run Flutter's Linter                                                                              |
| `flutter run`       | `rps run`           | Start the Dev Environment                                                                         |
| `flutter build apk` | `rps build android` | Build the android apk (Pass `--debug` for the debug build)                                        |
| `flutter build ipa` | `rps build ios`     | Build the ios ipa                                                                                 |
| `flutter install`   | `rps install`       | Install the app on the connected device. Can pass --release or --debug flags. (Default --release) |

## Environment Variables

Secrets and other configuration values are managed through environment variables. When developing locally, they can be configured by creating a `.env` file in the project's root (concordia_nav), the same location where `pubspec.yaml` is found.

> **Note**: Default values should be optimized for local development, such that
> a developer can clone and run the project successfully without having to
> override any configuration values.

The following variables can be configured:

| Variable            | Description                       | Value                      |
| ------------------- | --------------------------------- | -------------------------- |
| GOOGLE_MAPS_API_KEY | Used to integrate Google Maps API | `YOUR_GOOGLE_MAPS_API_KEY` |

## Generating RPS Scripts

1. First, install the `rps` package globally using: `dart pub global activate rps`
   > Make sure to add the `bin/` folder to your path in order to use `rps` from the command line.
   > Make sure to add the `bin/` folder to your path in order to use `rps` from the command line.
2. Then, use the `rps gen` command to generate the scripts.
3. You can now use any of the scripts defined in the `pubspec.yaml` file. Example: `rps test` will run the `rps test -r expanded`
   > On Windows, if you get an error along the lines of 'command not found', you might need to run `rps.bat` instead of just rps. (You can alias `rps.bat` to `rps` in your shell profile)
   > On Windows, if you get an error along the lines of 'command not found', you might need to run `rps.bat` instead of just rps. (You can alias `rps.bat` to `rps` in your shell profile)

[Link to rps repo](https://pub.dev/packages/rps).

## Enabling Pre-Commit Hooks

To enable the project's pre-commit hooks, run the following command: `git config core.hooksPath .githooks`

> If the script isn't executable, make it so on your respective operating system. Example: `chmod +x .githooks/pre-commit`

## iOS Builds

To build the iOS app, you need to create a file
`concordia_nav/ios/Flutter/Environment.xcconfig` with a bundle ID that is unique to your
Apple Developer team:

```
PRODUCT_BUNDLE_IDENTIFIER=com.YOURDOMAIN.concordia-nav
APPLE_TEAM_ID=A1B2C3D4E5
CONNAV_APP_NAME=Concordia Nav
```

