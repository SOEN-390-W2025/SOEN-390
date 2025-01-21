# SOEN 390

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

## Android Builds

To build the Android app, you need to create a file `env.json` at the repository root
which contains a bundle ID configured for your Google API keys:

```json
{
    "CONNAV_ANDROID_APP_ID": "com.YOURDOMAIN.concordia_nav",
    "CONNAV_APP_NAME": "Concordia Nav"
}
```

## iOS Builds

To build the iOS app, you need to create a file
`concordia_nav/ios/Flutter/Environment.xcconfig` with a bundle ID that is unique to your
Apple Developer team:

```
CONNAV_IOS_BUNDLE_ID=Concordia Nav
CONNAV_APP_NAME=com.YOURDOMAIN.concordia_nav
```