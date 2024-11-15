# BCMS Mobile APP

## Development Guide
- [Internal API Documentation](https://solopteltd.atlassian.net/wiki/spaces/TEAM/pages/144048130/BCMS+Internal+API+Documentation)
- [Microframework: Nylo Documentation](https://nylo.dev/)

## Getting Started

### Prerequisites
- Flutter SDK [here](https://docs.flutter.dev/get-started/install/windows/mobile?tab=download)
- Android Studio with Flutter plugin (Search for plugin inside Android Studio)

### Installation
1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run `cp .env.example .env` to copy the local environment variables.

## Running the App
1. Open Android Studio.
2. Install the Flutter plugin if not already installed.
3. Wait for the project sync & build.
4. Android Studio may prompt you to download missing dependencies like Dart SDK and ETC.
5. Run the project from Android Studio.

## Project Structure
- We use the MVVM concept for the structure and some BLoC for the backend side using nylo frameworks.
- The folder with many changes is inside the "lib" folder.
- Refer to the example project for full implementation, including fetching APIs and more [here](https://drive.google.com/file/d/1b2ROzaonpxCP1Bvb57Ar1syJUlURe-6z/view?usp=sharing).
- Full documentation for nylo is available [here](https://nylo.dev/docs/5.20.0/installation).

## APK Generation
**To generate the APK or IPA files, please run the following commands:**
```
flutter build apk --obfuscate --dart-define-from-file=.env_prod
flutter build ipa --obfuscate --dart-define-from-file=.env_prod
```
