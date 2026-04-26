// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'openScale';

  @override
  String get overview => 'Обзор';

  @override
  String get graph => 'График';

  @override
  String get table => 'Таблица';

  @override
  String get statistics => 'Статистика';

  @override
  String get insights => 'Аналитика';

  @override
  String get addMeasurement => 'Добавить измерение';

  @override
  String get noMeasurementsYet => 'Пока нет измерений';

  @override
  String get settings => 'Настройки';

  @override
  String get profile => 'Профиль';

  @override
  String get users => 'Пользователи';

  @override
  String get manageUsersAndProfiles => 'Управление пользователями и профилями';

  @override
  String get connectivity => 'Подключения';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get connectBleScale => 'Подключить весы BLE';

  @override
  String get data => 'Данные';

  @override
  String get dataManagement => 'Управление данными';

  @override
  String get importExportBackup => 'Импорт, экспорт, резервное копирование';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get lightDarkSystem => 'Светлая, тёмная, системная';

  @override
  String get units => 'Единицы';

  @override
  String get weightHeight => 'Вес, рост';

  @override
  String get about => 'О приложении';

  @override
  String get aboutOpenScale => 'О приложении openScale';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get license => 'Лицензия';

  @override
  String get gplV3 => 'GPL v3';

  @override
  String get noDataForSelectedPeriod => 'Нет данных за выбранный период';

  @override
  String get noMeasurements => 'Нет измерений';

  @override
  String get date => 'Дата';

  @override
  String get weight => 'Вес';

  @override
  String get bmi => 'ИМТ';

  @override
  String get fatPercent => 'Жир %';

  @override
  String get waterPercent => 'Вода %';

  @override
  String get musclePercent => 'Мышцы %';

  @override
  String get week => 'Неделя';

  @override
  String get month => 'Месяц';

  @override
  String get year => 'Год';

  @override
  String get minimum => 'Минимум';

  @override
  String get maximum => 'Максимум';

  @override
  String get last => 'Последнее';

  @override
  String get change => 'Изменение';

  @override
  String get count => 'Количество';

  @override
  String get noDataYet => 'Пока нет данных';

  @override
  String get monthlyChange => 'Изменение за месяц';

  @override
  String get currentStreak => 'Текущая серия';

  @override
  String get mostActiveDay => 'Самый активный день';

  @override
  String get goalProgress => 'Прогресс к цели';

  @override
  String get avgWeeklyWeighIns => 'Среднее взвешиваний в неделю';

  @override
  String get lastMeasurement => 'Последнее измерение';

  @override
  String get monday => 'Понедельник';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get days => 'дней';

  @override
  String get perWeek => 'в неделю';

  @override
  String kgThisMonth(String value) {
    return '$value кг за месяц';
  }

  @override
  String get setGoalInUserSettings =>
      'Установите цель в настройках пользователя';

  @override
  String streakDays(int count) {
    return '$count дней';
  }

  @override
  String avgWeeklyCount(String count) {
    return '$count в неделю';
  }

  @override
  String get measurement => 'Измерение';

  @override
  String get measurementNotFound => 'Измерение не найдено';

  @override
  String get dateTime => 'Дата и время';

  @override
  String get deleteMeasurement => 'Удалить измерение';

  @override
  String get actionCannotBeUndone => 'Это действие нельзя отменить.';

  @override
  String get save => 'Сохранить';

  @override
  String get comment => 'Комментарий';

  @override
  String get saveMeasurement => 'Сохранить измерение';

  @override
  String get enterValidWeight => 'Введите корректный вес';

  @override
  String get edit => 'Редактировать';

  @override
  String get delete => 'Удалить';

  @override
  String get deleteUser => 'Удалить пользователя';

  @override
  String deleteUserNameData(String name) {
    return 'Удалить \"$name\" и все данные?';
  }

  @override
  String get editUser => 'Редактирование пользователя';

  @override
  String get addUser => 'Добавить пользователя';

  @override
  String get name => 'Имя';

  @override
  String get heightCm => 'Рост (см)';

  @override
  String get goalWeightKg => 'Целевой вес (кг)';

  @override
  String get birthday => 'Дата рождения';

  @override
  String get cancel => 'Отмена';

  @override
  String get scanning => 'Поиск...';

  @override
  String get scan => 'Поиск';

  @override
  String get disconnect => 'Отключить';

  @override
  String get noDeviceConnected => 'Устройство не подключено';

  @override
  String get scanNearbyBle => 'Поиск весов BLE поблизости';

  @override
  String get searchingForDevices => 'Поиск устройств...';

  @override
  String get noDevicesFound => 'Устройства не найдены';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get connect => 'Подключить';

  @override
  String get export => 'Экспорт';

  @override
  String get exportCsv => 'Экспорт CSV';

  @override
  String get exportMeasurementsCsv => 'Экспорт измерений в файл CSV';

  @override
  String get importCsv => 'Импорт CSV';

  @override
  String get importMeasurementsCsv => 'Импорт измерений из файла CSV';

  @override
  String get backup => 'Резервная копия';

  @override
  String get backupDatabase => 'Резервное копирование базы данных';

  @override
  String get saveDatabaseCopy => 'Сохранить копию базы данных';

  @override
  String get restoreDatabase => 'Восстановить базу данных';

  @override
  String get restoreFromBackup => 'Восстановить из резервной копии';

  @override
  String get dangerZone => 'Опасная зона';

  @override
  String get clearAllData => 'Очистить все данные';

  @override
  String get deleteAllMeasurementsAllUsers =>
      'Удалить все измерения для всех пользователей';

  @override
  String get clearDataWarning =>
      'Все измерения для всех пользователей будут безвозвратно удалены. Это действие нельзя отменить.';

  @override
  String get allDataCleared => 'Все данные очищены';

  @override
  String get csvExportInitiated => 'Экспорт CSV запущен';

  @override
  String get csvImportInitiated => 'Импорт CSV запущен';

  @override
  String get backupInitiated => 'Резервное копирование запущено';

  @override
  String get restoreInitiated => 'Восстановление запущено';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get ok => 'OK';

  @override
  String get all => 'Все';

  @override
  String get fat => 'Жир';

  @override
  String get water => 'Вода';

  @override
  String get muscle => 'Мышцы';

  @override
  String get lbm => 'БМТ';

  @override
  String get bone => 'Кости';

  @override
  String get waist => 'Талия';

  @override
  String get visceral => 'Висцеральный жир';

  @override
  String get kg => 'кг';
}
