# AdiMusic

Android music player — rebranded from [LastWave-Native](https://github.com/Clash-Projects/LastWave-Native) by Clash-Projects.

**Rebranded by Aditya Jha** · App name: AdiMusic

## About

AdiMusic is a fork of LastWave-Native (v4.2.4) with the app name, widgets, and
about-screen rebranded to AdiMusic. The package name (`com.lastwave.app`) is
intentionally unchanged to keep the build and native bindings working.

Original project, authorship, and license belong to Clash-Projects.
This fork is distributed under the same **GPL-3.0** license — see `LICENSE`.

## APK

Every push to `main` builds a debug APK with GitHub Actions
(`.github/workflows/build-apk.yml`) and publishes it under
**Releases** as `AdiMusic-v4.2.4.apk`.

To install on your phone: download the APK from Releases and allow
"Install unknown apps" when Android asks.

## Build locally

Requires JDK 17, Android SDK (platform 37), NDK 28.2.13610387,
CMake 3.22.1, and Gradle 9.3.1:

```sh
gradle :app:assembleDebug
```
