# AURORA APP — Flutter / ОС Аврола

**Цель:** Переписание openScale на Flutter с минимальными зависимостями для ОС Аврора.

## OVERVIEW

Flutter-приложение для отслеживания веса и метрик тела. Целевая платформа — ОС Аврора (Linux/Sailfish-based). Минимум зависимостей.

## STRUCTURE

```
aurora_app/
├── lib/
│   ├── main.dart                    # Точка входа
│   ├── core/
│   │   ├── database/                # SQLite через sqflite
│   │   │   ├── app_database.dart    # Открытие БД, миграции
│   │   │   └── dao/                 # Data Access Objects
│   │   ├── models/                  # Чистые data-классы (User, Measurement, MeasurementType, ...)
│   │   ├── bloc/                    # BLoC/Cubit (flutter_bloc)
│   │   │   ├── user/                # UserBloc, UserState, UserEvent
│   │   │   ├── measurement/         # MeasurementBloc, MeasurementState, MeasurementEvent
│   │   │   ├── settings/            # SettingsBloc, SettingsState
│   │   │   └── bluetooth/           # BluetoothBloc, BluetoothState
│   │   ├── services/
│   │   │   ├── ble/                 # BLE-абстракция (интерфейс + platform impl)
│   │   │   ├── backup/              # Бэкап/восстановление БД
│   │   │   └── import_export/       # CSV импорт/экспорт
│   │   └── utils/                   # Calculation, Conversion, Logging
│   ├── ui/
│   │   ├── theme/                   # AppTheme, цвета, типография
│   │   ├── navigation/              # Router (GoRouter)
│   │   ├── screens/
│   │   │   ├── overview/            # Главный экран + детали измерения
│   │   │   ├── graph/               # Графики (fl_chart)
│   │   │   ├── table/               # Таблица измерений
│   │   │   ├── statistics/          # Статистика
│   │   │   ├── insights/            # Аналитика/тренды
│   │   │   ├── settings/            # Настройки (пользователи, BLE, данные, ...)
│   │   │   └── measurement_detail/  # Детали/редактирование измерения
│   │   ├── widgets/                 # Переиспользуемые виджеты
│   │   │   └── dialogs/             # Диалоги (дата, число, текст, ...)
│   │   └── shared/                  # Общие утилиты UI
│   └── l10n/                        # Локализация (ARB-файлы)
├── test/
├── linux/                           # Aurora OS Linux runner
├── pubspec.yaml
├── analysis_options.yaml
└── AGENTS.md                        # Этот файл
```

## ЗАВИСИМОСТИ (минимум)

| Пакет | Версия | Назначение |
|-------|--------|------------|
| `flutter_bloc` | ^9.x | State management (BLoC/Cubit) |
| `sqflite` | ^2.x | SQLite (доступен на Aurora через FFI) |
| `fl_chart` | ^0.69 | Графики (чистый Dart, Canvas) |
| `go_router` | ^14.x | Декларативная навигация |
| `equatable` | ^2.x | Value equality для BLoC states/events |
| `uuid` | ^4.x | Генерация ID |
| `intl` | ^0.19 | Локализация дат/чисел |
| `path` | ^1.9 | Работа с путями |
| `csv` | ^6.x | Импорт/экспорт CSV |

**НЕ ДОБАВЛЯТЬ без согласования:**
- Пакеты с native-кодом, не имеющие Linux-backend
- Пакеты с internet permission (приложение оффлайн)
-reflectable, build_runner (кроме генерации l10n)

## ПРАВИЛА КОДИРОВАНИЯ

### Архитектура

- **BLoC/Cubit** для всего state management. Никакого setState() в экранах.
- **Repository pattern** между BLoC и database/DAO. BLoC не знает про SQL.
- **Интерфейсы (abstract class)** для всех сервисов. Конкретные реализации через DI.
- **DI через GetIt** (один регистр в main.dart). Никакого service locator в виджетах.
- Модели — immutable data-классы с `Equatable`. Никаких mutable-полей.

### Структура BLoC

```dart
// Каждый BLoC/Cubit в отдельной папке: bloc, event, state
measurement_bloc.dart       // или measurement_cubit.dart
measurement_event.dart      // только для Bloc, не Cubit
measurement_state.dart
```

### База данных

- **sqflite** + ручной SQL. Никакого ORM.
- Миграции — нумерованные функции в `app_database.dart` (как Room migration).
- Версия БД начинается с 1. Переносим схему из Room (v14), но нумерация своя.
- Все SQL-запросы — константы в DAO-классах. Никакой конкатенации строк.
- Транзакции для batch-операций (insert measurement + values).

### UI

- **Material 3**. Тема в `ui/theme/`.
- Каждый экран — отдельный файл в своей папке.
- Переиспользуемые виджеты — в `ui/widgets/`.
- Диалоги — отдельные функции/виджеты в `ui/widgets/dialogs/`.
- Навигация через GoRouter. Роуты — константы в `ui/navigation/app_router.dart`.

### BLE (ОС Аврора) — решение принято

**Рекомендация: `flutter_reactive_ble_aurora` + кастомный SPP-плагин**

Критический контекст: Aurora OS использует **форк Flutter** (`flutter-aurora`), pub.dev-пакеты **НЕ работают** напрямую. Все плагины — только из репозиториев hub.mos.ru.

**GATT-весы (39 из 40): `flutter_reactive_ble_aurora`**
- Источник: hub.mos.ru/auroraos/flutter/flutter-community-plugins/flutter_reactive_ble_aurora
- Основан на `flutter_reactive_ble` ^5.3.1 (от Philips Hue)
- Полная поддержка: scan, connect, discover services, read/write/subscribe characteristics, MTU
- Совместимость: Flutter 3.32.7+, Aurora OS 5.0.0+

```yaml
dependencies:
  flutter_reactive_ble: ^5.3.1
  flutter_reactive_ble_aurora:
    git:
      url: https://developer.auroraos.ru/git/flutter/flutter-community-plugins/flutter_reactive_ble_aurora.git
```

**SPP-весы (iHealth HS3): Кастомный Qt-плагин**
- Aurora нативно поддерживает SPP через `bluez-qt` (демо: hub.mos.ru/auroraos/demos/BluetoothSpp)
- Создать Flutter Qt plugin: `flutter-aurora create --template=plugin --platform=aurora`
- Обернуть bluez-qt SPP: connectSPP(), readSPP(), writeSPP() через MethodChannel
- Требуется `Bluetooth` permission в .desktop-файле

**Архитектура:**
```
lib/core/services/ble/
├── ble_interface.dart        # Абстрактный интерфейс
├── ble_reactive_impl.dart    # Реализация через flutter_reactive_ble_aurora
├── ble_mock.dart             # Mock для dev/test
└── spp_aurora_plugin.dart    # MethodChannel-обёртка для SPP (iHealth HS3)
```

- BLE-слой за abstract interface. Конкретная реализация — через flutter_reactive_ble_aurora.
- **НЕТ flutter_blue_plus** — pub.dev-пакеты не работают с flutter-aurora.

### Локализация

- ARB-файлы в `lib/l10n/`.
- Русский (ru) — основной язык. Английский (en) — запасной.
- Все строки в UI — через `AppLocalizations.of(context)!.xxx`.
- Никаких хардкода-строк.

### Тестирование

- `bloc_test` для BLoC/Cubit.
- `sqflite_common_ffi` для тестов БД на desktop.
- `flutter_test` для виджет-тестов.
- Модели тестируются на equality/serialization.
- Тесты в `test/` зеркально структуре `lib/`.

## АНТИ-ПАТТЕРНЫ (ЭТОТ ПРОЕКТ)

- **НЕ ИСПОЛЬЗОВАТЬ** `setState()` — только BLoC/Cubit
- **НЕ ДОБАВЛЯТЬ** зависимости без записи в AGENTS.md
- **НЕ ХАРДКОДИТЬ** строки — только через l10n
- **НЕ ИСПОЛЬЗОВАТЬ** `dynamic`, `as` (кроме Platform channels), `Object?`
- **НЕ ДОБАВЛЯТЬ** Flutter/Dart файлы в `android_app/` — это отдельный проект
- **НЕ ИСПОЛЬЗОВАТЬ** `dart:io` Platform в lib/ — только через абстракцию
- **ВСЕГДА** immutable модели с `Equatable`
- **ВСЕГДА** Dispose controllers в виджетах
- **ВСЕГДА** Отдельный файл для BLoC state/event
- **ВСЕГДА** Константы для SQL-запросов

## СООТВЕТСТВИЕ АНДРОИД-ВЕРСИИ

При портировании из `android_app/`:

| Android (Kotlin) | Flutter (Dart) |
|---|---|
| Room Entity | `lib/core/models/` data class |
| Room DAO | `lib/core/database/dao/` class |
| Facade | Repository + BLoC |
| UseCase | BLoC logic or dedicated service |
| ViewModel | BLoC/Cubit |
| Compose Screen | Widget screen |
| Navigation Compose | GoRouter |
| DataStore | SharedPreferences или sqflite таблица |
| Hilt DI | GetIt |
| Blessed BLE | Platform channel + BlueZ |
| Vico charts | fl_chart |
| LogManager | `logging` package |

## КОМАНДЫ

```bash
# Запуск на desktop (для разработки)
cd aurora_app && flutter run -d linux

# Запуск тестов
cd aurora_app && flutter test

# Анализ кода
cd aurora_app && flutter analyze

# Сборка для Aurora
cd aurora_app && flutter build linux

# Генерация l10n
cd aurora_app && flutter gen-l10n
```

## ЗАМЕТКИ

- ОС Аврора основана на Sailfish OS (Linux, Wayland, BlueZ).
- Flutter на Аврора работает через community embedder (aurora-flutter).
- BLE на Аврора — через BlueZ/D-Bus, НЕ через Android BLE API.
- Приложение полностью оффлайн — никаких internet permissions.
- Лицензия: GPL v3 (как оригинал).
