# PROJECT KNOWLEDGE BASE

**Generated:** 2026-04-25
**Commit:** ceeeda58
**Branch:** master

## OVERVIEW

openScale — open-source weight/body metrics tracker for Android with BLE scale support. Native Kotlin + Jetpack Compose app (NOT Flutter despite repo name). Includes Arduino MCU firmware for DIY Bluetooth scales.

## STRUCTURE

```
openScale-flutter/
├── android_app/       # Native Android app (Kotlin, Compose, Room, Hilt)
├── arduino_mcu/       # Arduino firmware for custom DIY BLE scale
├── docs/              # Scale product photos, app screenshots, custom_scale hw docs
├── fastlane/          # Play Store/F-Droid deployment metadata (en-GB only)
├── .github/workflows/ # CI: master→debug APK, openScale-3.0→beta APK
├── Gemfile            # Ruby deps for fastlane
└── README.md
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add BLE scale driver | `android_app/.../core/bluetooth/scales/` | Extend `ScaleDeviceHandler`, register in `ScaleFactory` |
| Add body composition lib | `android_app/.../core/bluetooth/libs/` | Pure math, tested with snapshot + property tests |
| Add/modify screen | `android_app/.../ui/screen/` | Compose, route in `Routes.kt` + `AppNavigation.kt` |
| Add business logic | `android_app/.../core/usecase/` | `@Singleton`, inject into facades |
| Modify data model | `android_app/.../core/data/` | Room entities, update migration in `AppDatabase` |
| Change settings | `android_app/.../core/facade/SettingsFacade.kt` | DataStore-backed, add key in `SettingsPreferenceKeys` |
| Fix BLE connection | `android_app/.../core/service/BleConnector.kt` | GATT lifecycle, event routing |
| Add measurement type | `android_app/.../core/data/Enums.kt` | Add `MeasurementTypeKey` + default in `OpenScaleApp.kt` |
| Android build config | `android_app/app/build.gradle.kts` | 4 variants: debug, release, beta, oss |
| Arduino firmware | `arduino_mcu/openScale_MCU/openScale_MCU.ino` | Single-file sketch, ATmega328P |
| Deployment | `fastlane/Fastfile` | 4 lanes: release, oss, deployOSS, deployGitHubRelease |

## CONVENTIONS

- **Language**: 100% Kotlin (zero Java files). Arduino side is C++/Arduino.
- **UI**: 100% Jetpack Compose with Material 3. No XML layouts, no Fragments.
- **DI**: Hilt everywhere. `@HiltAndroidApp`, `@AndroidEntryPoint`, `@HiltViewModel`, `@Singleton @Inject`.
- **Architecture**: Clean MVVM with Facade layer. SharedViewModel delegates to SettingsFacade via Kotlin `by` delegation.
- **Database**: Room (v14) with 8 migrations (v6→v14). Schemas exported to `app/schemas/`.
- **Settings**: DataStore Preferences (not Room). All keys in `SettingsPreferenceKeys`.
- **BLE**: Blessed Kotlin library. ScaleFactory + Strategy pattern per vendor (40+ handlers).
- **Testing**: Google Truth assertions, snapshot + property-based. JVM unit tests only for body composition libs.
- **Code style**: `kotlin.code.style=official`. No ktlint/detekt configured.
- **ProGuard**: Obfuscation disabled intentionally (`-keepnames class *`).
- **kapt** used for Hilt/Room (not KSP yet).
- **Localization**: Weblate for app strings. Fastlane store listing only en-GB.

## ANTI-PATTERNS (THIS PROJECT)

- **DO NOT** suppress type errors — no `as Any`, no `@Suppress`
- **DO NOT** add Flutter/Dart files — repo name is legacy, this is native Android
- **DO NOT** clear `lefuFrag` in ESCS20MHandler mid-stream (5Hz weight frames interleave)
- **DO NOT** send config to QN scales before 0x12 protocol detection frame
- **DO NOT** use mock frameworks in tests — no Mockk/Mockito in the project
- **NEVER** claim Renpho when QN services are present (device conflict)
- **NEVER** use averages in StatisticsScreen — always raw enriched values
- **ALWAYS** use `LogManager` not `println` for logging (one println debug leftover in `MeasurementDetailScreen.kt:209`)
- **ALWAYS** ACK BeurerSanitas notifications
- **ALWAYS** use `cm` for height, `kg` for weight in `ScaleUser`

## UNIQUE STYLES

- **Measurement pipeline**: `MeasurementFacade.pipeline()` chains query→enrich→filter→smooth→aggregate into single reactive `Flow<List<AggregatedMeasurement>>`. Screens consume with zero transformation.
- **Scale driver registration**: Ordered list in `ScaleFactory.modernKotlinHandlers` — earlier = higher priority. No annotations, no XML.
- **TuningProfile**: Conservative/Balanced/Aggressive controls BLE timing per-device.
- **3 link modes**: GATT (32 scales), BROADCAST_ONLY (5 scales), CLASSIC_SPP (1 scale: iHealth HS3).
- **Test snapshots**: Regression fixtures frozen from current output. `dump_allFixtures()` helper to regenerate after intentional formula changes.

## COMMANDS

```bash
# Build debug APK (from android_app/)
cd android_app && ./gradlew assembleDebug

# Build release
cd android_app && ./gradlew assembleRelease

# Run unit tests (body composition libs only)
cd android_app && ./gradlew test

# Run instrumented tests (requires device/emulator)
cd android_app && ./gradlew connectedAndroidTest

# Deploy via fastlane
bundle exec fastlane release        # Build release APK
bundle exec fastlane deployOSS      # Upload to Play Store
```

## NOTES

- Keystore files referenced at `../../openScale.keystore` (2 levels above repo) — not in VCS.
- CI builds only APKs — no tests, no lint, no static analysis in CI pipelines.
- `minSdk=31` (Android 12), `targetSdk=36`, `compileSdk=36`.
- Room DB at version 14 with schema exports in `app/schemas/`.
- Fastlane Appfile has typo: `fastlane_secrect_keys.json` (should be `secret`).
- GPL v3 license. Third-party attributions in `CREDITS` file.
