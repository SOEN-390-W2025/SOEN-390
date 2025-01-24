# SOEN 390

[![codecov](https://codecov.io/github/NathanGrenier/SOEN-390/graph/badge.svg?token=QWLVNVQUYB)](https://codecov.io/github/NathanGrenier/SOEN-390)

# About

## Team Members

| Name           | Student ID | Email                     |
| -------------- | ---------- | ------------------------- |
| Nathan Grenier | 40250986   | nathangrenier01@gmail.com |

# Getting Started


## Useful Flutter Commands

| Command           | Description               |
| ----------------- | ------------------------- |
| `flutter analyze` | Run Flutter's Linter      |
| `flutter run`     | Start the Dev Environment |

## Generating RPS Scripts

1. First, install the `rps` package globally using: `dart pub global activate rps`
    > Make sure to add the `bin/` folder to your path in order to use `rps` from the command line.
2. Then, use the `rps gen` command to generate the scripts.
3. You can now use any of the scripts defined in the `pubspec.yaml` file. Example: `rps test` will run the `rps test -r expanded`
    > On Windows, if you get an error along the lines of 'command not found', you might need to run `rps.bat` instead of just rps. (You can alias `rps.bat` to `rps` in your shell profile)

[Link to rps repo](https://pub.dev/packages/rps).

## iOS Builds

To build the iOS app, you need to create a file
`concordia_nav/ios/Flutter/Environment.xcconfig` with a bundle ID that is unique to your
Apple Developer team:

```
CONNAV_IOS_BUNDLE_ID=Concordia Nav
CONNAV_APP_NAME=com.YOURDOMAIN.concordia_nav
```