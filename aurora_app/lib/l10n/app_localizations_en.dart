// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'openScale';

  @override
  String get overview => 'Overview';

  @override
  String get graph => 'Graph';

  @override
  String get table => 'Table';

  @override
  String get statistics => 'Statistics';

  @override
  String get insights => 'Insights';

  @override
  String get addMeasurement => 'Add measurement';

  @override
  String get noMeasurementsYet => 'No measurements yet';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get users => 'Users';

  @override
  String get manageUsersAndProfiles => 'Manage users and profiles';

  @override
  String get connectivity => 'Connectivity';

  @override
  String get bluetooth => 'Bluetooth';

  @override
  String get connectBleScale => 'Connect BLE scale';

  @override
  String get data => 'Data';

  @override
  String get dataManagement => 'Data management';

  @override
  String get importExportBackup => 'Import, export, backup';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get lightDarkSystem => 'Light, dark, system';

  @override
  String get units => 'Units';

  @override
  String get weightHeight => 'Weight, height';

  @override
  String get about => 'About';

  @override
  String get aboutOpenScale => 'About openScale';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get license => 'License';

  @override
  String get gplV3 => 'GPL v3';

  @override
  String get noDataForSelectedPeriod => 'No data for selected period';

  @override
  String get noMeasurements => 'No measurements';

  @override
  String get date => 'Date';

  @override
  String get weight => 'Weight';

  @override
  String get bmi => 'BMI';

  @override
  String get fatPercent => 'Fat %';

  @override
  String get waterPercent => 'Water %';

  @override
  String get musclePercent => 'Muscle %';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get last => 'Last';

  @override
  String get change => 'Change';

  @override
  String get count => 'Count';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get monthlyChange => 'Monthly change';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get mostActiveDay => 'Most active day';

  @override
  String get goalProgress => 'Goal progress';

  @override
  String get avgWeeklyWeighIns => 'Average weekly weigh-ins';

  @override
  String get lastMeasurement => 'Last measurement';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get days => 'days';

  @override
  String get perWeek => 'per week';

  @override
  String kgThisMonth(String value) {
    return '$value kg this month';
  }

  @override
  String get setGoalInUserSettings => 'Set a goal in user settings';

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String avgWeeklyCount(String count) {
    return '$count per week';
  }

  @override
  String get measurement => 'Measurement';

  @override
  String get measurementNotFound => 'Measurement not found';

  @override
  String get dateTime => 'Date & Time';

  @override
  String get deleteMeasurement => 'Delete measurement';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get save => 'Save';

  @override
  String get comment => 'Comment';

  @override
  String get saveMeasurement => 'Save measurement';

  @override
  String get enterValidWeight => 'Enter a valid weight';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteUser => 'Delete user';

  @override
  String deleteUserNameData(String name) {
    return 'Delete \"$name\" and all their data?';
  }

  @override
  String get editUser => 'Edit user';

  @override
  String get addUser => 'Add user';

  @override
  String get name => 'Name';

  @override
  String get heightCm => 'Height (cm)';

  @override
  String get goalWeightKg => 'Goal weight (kg)';

  @override
  String get birthday => 'Birthday';

  @override
  String get cancel => 'Cancel';

  @override
  String get scanning => 'Scanning...';

  @override
  String get scan => 'Scan';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get noDeviceConnected => 'No device connected';

  @override
  String get scanNearbyBle => 'Scan for nearby BLE scales';

  @override
  String get searchingForDevices => 'Searching for devices...';

  @override
  String get noDevicesFound => 'No devices found';

  @override
  String get unknown => 'Unknown';

  @override
  String get connect => 'Connect';

  @override
  String get export => 'Export';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportMeasurementsCsv => 'Export measurements to CSV file';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get importMeasurementsCsv => 'Import measurements from CSV file';

  @override
  String get backup => 'Backup';

  @override
  String get backupDatabase => 'Backup database';

  @override
  String get saveDatabaseCopy => 'Save a copy of the database';

  @override
  String get restoreDatabase => 'Restore database';

  @override
  String get restoreFromBackup => 'Restore from a backup file';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get deleteAllMeasurementsAllUsers =>
      'Delete all measurements for all users';

  @override
  String get clearDataWarning =>
      'This will permanently delete all measurements for all users. This cannot be undone.';

  @override
  String get allDataCleared => 'All data cleared';

  @override
  String get csvExportInitiated => 'CSV export initiated';

  @override
  String get csvImportInitiated => 'CSV import initiated';

  @override
  String get backupInitiated => 'Backup initiated';

  @override
  String get restoreInitiated => 'Restore initiated';

  @override
  String get confirm => 'Confirm';

  @override
  String get ok => 'OK';

  @override
  String get all => 'All';

  @override
  String get fat => 'Fat';

  @override
  String get water => 'Water';

  @override
  String get muscle => 'Muscle';

  @override
  String get lbm => 'LBM';

  @override
  String get bone => 'Bone';

  @override
  String get waist => 'Waist';

  @override
  String get visceral => 'Visceral';

  @override
  String get kg => 'kg';
}
