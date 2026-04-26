# ANDROID APP

Native Kotlin/Jetpack Compose app for openScale. Package: `com.health.openscale`, v3.1.0 (code 74).

## OVERVIEW

Weight/body metrics tracker with BLE scale support. Single-activity Compose UI with Clean MVVM + Facade architecture.

## STRUCTURE

```
app/src/main/java/com/health/openscale/
├── MainActivity.kt              # Single Activity, @AndroidEntryPoint
├── OpenScaleApp.kt              # @HiltAndroidApp, seeds default measurement types
├── core/
│   ├── bluetooth/
│   │   ├── scales/              # 43 scale device handlers (Strategy pattern)
│   │   │   ├── ScaleDeviceHandler.kt       # Abstract base for all drivers
│   │   │   ├── StandardWeightProfileHandler.kt  # BT Standard Weight Profile base
│   │   │   ├── ModernScaleAdapter.kt       # Adapter base (tuning, event streams)
│   │   │   ├── GattScaleAdapter.kt         # BLE GATT transport
│   │   │   ├── BroadcastScaleAdapter.kt    # BLE broadcast-only transport
│   │   │   ├── SppScaleAdapter.kt          # Bluetooth Classic SPP transport
│   │   │   └── [38 vendor handlers]        # One file per scale brand/model
│   │   ├── libs/                # Body composition math libraries (MiScale, Yunmai, etc.)
│   │   ├── data/                # ScaleMeasurement, ScaleUser DTOs
│   │   ├── ScaleCommunicator.kt # Interface for connection lifecycle
│   │   └── ScaleFactory.kt      # @Singleton factory, ordered handler list
│   ├── data/                    # Room entities: User, Measurement, MeasurementValue, MeasurementType, UserGoals, Enums
│   ├── database/                # AppDatabase (v14), 5 DAOs, DatabaseRepository, TypeConverters, ContentProvider
│   ├── facade/                  # 5 facades: Measurement, Bluetooth, User, Settings, DataManagement
│   ├── model/                   # Domain DTOs: EnrichedMeasurement, AggregatedMeasurement, MeasurementInsight, etc.
│   ├── service/                 # BleScanner, BleConnector, MeasurementEnricher, MeasurementEvaluator, TrendCalculator
│   ├── usecase/                 # 17 single-responsibility use cases (@Singleton @Inject)
│   ├── utils/                   # LogManager, CalculationUtils, ConverterUtils, LocaleUtils
│   └── worker/                  # BackupWorker, ReminderWorker, BootReceiver (HiltWorkerFactory)
├── ui/
│   ├── navigation/              # Routes.kt (constants), AppNavigation.kt (NavHost, 18+ routes)
│   ├── shared/                  # SharedViewModel (central hub), TopBarAction, SnackbarEvent
│   ├── screen/
│   │   ├── overview/            # OverviewScreen, MeasurementDetailScreen
│   │   ├── graph/               # GraphScreen (Vico charts)
│   │   ├── table/               # TableScreen
│   │   ├── statistics/          # StatisticsScreen
│   │   ├── insights/            # InsightsScreen (weekday patterns, trends)
│   │   ├── settings/            # 13 screens + SettingsViewModel + BluetoothViewModel
│   │   ├── components/          # MeasurementChart, MeasurementChartFilter, gauge/filter components
│   │   └── dialog/              # 10 input dialogs (date, number, text, color, etc.)
│   ├── theme/                   # Color, Type, Theme (Material 3 + dynamic color)
│   └── widget/                  # Glance MeasurementWidget + config activity
app/src/test/                    # 9 JVM unit tests (body composition libs)
app/src/androidTest/             # 1 instrumented test (BackupRestoreUseCases)
app/schemas/                     # 8 Room schema exports (v7-v14)
```

## WHERE TO LOOK

| Task | Start Here |
|------|------------|
| Understand data flow | `core/facade/MeasurementFacade.kt` — the pipeline orchestrator |
| Add a new BLE scale | `core/bluetooth/scales/` — see root AGENTS.md for full instructions |
| Modify a screen | `ui/screen/<feature>/` — Composable functions |
| Add a route | `ui/navigation/Routes.kt` (constant) + `AppNavigation.kt` (NavHost entry) |
| Change measurement logic | `core/usecase/MeasurementCrudUseCases.kt` or `MeasurementTransformationUseCase.kt` |
| Add derived value | `core/database/DatabaseRepository.kt` → `recalculateDerivedValuesForMeasurement()` |
| Fix DB migration | `core/database/AppDatabase.kt` — add migration, bump version |
| Debug BLE connection | `core/service/BleConnector.kt` → `core/bluetooth/scales/GattScaleAdapter.kt` |
| Change chart rendering | `ui/screen/components/MeasurementChart.kt` (Vico library) |
| Configure build variant | `app/build.gradle.kts` (debug/release/beta/oss) |

## ARCHITECTURE

```
Compose Screens → ViewModels → Facades → UseCases → Repository/Services → Room/DataStore/BLE
```

- **SharedViewModel** is central hub — delegates `SettingsFacade by settingsFacade`
- **MeasurementFacade.pipeline()**: query→enrich→filter→smooth→aggregate reactive flow
- **ViewModels are thin** — BluetoothViewModel just exposes facade flows
- **All use cases return `Result<T>`** for edge error handling
- **ContentProvider** (`DatabaseProvider`) exposes data to openScale-sync companion app

## CONVENTIONS

- Room entities are `data class` — create new instances for mutations (immutability)
- Facades orchestrate use cases; use cases contain business logic
- BLE handlers never block/sleep — adapter serializes all I/O via queued operations
- `publish(ScaleMeasurement)` is the only way to emit measurements from handlers
- Test naming: `snake_case` pattern `{what}_{condition}_{expectedOutcome}`
- Test assertions: Google Truth `assertThat()` with `isWithin(EPS).of(expected)` (EPS=1e-3f)

## ANTI-PATTERNS

- `println` in `ui/screen/overview/MeasurementDetailScreen.kt:209` — should use `LogManager`
- RenphoHandler has 4 scattered TODOs for unimplemented body composition parsing
- DebugGattHandler never publishes — diagnostic only, don't use for real devices
- No ViewModel/DAO/Repository unit tests — only body composition libs are tested
