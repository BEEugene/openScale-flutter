import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'openScale'**
  String get appTitle;

  /// Navigation tab label for overview screen
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Navigation tab label for graph screen
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get graph;

  /// Navigation tab label for table screen
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// Navigation tab label for statistics screen
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Navigation tab label for insights screen
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Button/tooltip to add a new measurement
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get addMeasurement;

  /// Empty state message on overview screen
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurementsYet;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Users management screen title and settings item
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// Subtitle for users settings item
  ///
  /// In en, this message translates to:
  /// **'Manage users and profiles'**
  String get manageUsersAndProfiles;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivity;

  /// Bluetooth screen title and settings item
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get bluetooth;

  /// Subtitle for bluetooth settings item
  ///
  /// In en, this message translates to:
  /// **'Connect BLE scale'**
  String get connectBleScale;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// Data management screen title and settings item
  ///
  /// In en, this message translates to:
  /// **'Data management'**
  String get dataManagement;

  /// Subtitle for data management settings item
  ///
  /// In en, this message translates to:
  /// **'Import, export, backup'**
  String get importExportBackup;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme settings item
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Subtitle for theme settings item
  ///
  /// In en, this message translates to:
  /// **'Light, dark, system'**
  String get lightDarkSystem;

  /// Units settings item
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// Subtitle for units settings item
  ///
  /// In en, this message translates to:
  /// **'Weight, height'**
  String get weightHeight;

  /// Settings section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// About settings item title
  ///
  /// In en, this message translates to:
  /// **'About openScale'**
  String get aboutOpenScale;

  /// Version display
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// License settings item title
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// License name
  ///
  /// In en, this message translates to:
  /// **'GPL v3'**
  String get gplV3;

  /// Empty chart state
  ///
  /// In en, this message translates to:
  /// **'No data for selected period'**
  String get noDataForSelectedPeriod;

  /// Empty table state
  ///
  /// In en, this message translates to:
  /// **'No measurements'**
  String get noMeasurements;

  /// Table column header
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Body Mass Index label
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// Body fat percentage column header
  ///
  /// In en, this message translates to:
  /// **'Fat %'**
  String get fatPercent;

  /// Body water percentage column header
  ///
  /// In en, this message translates to:
  /// **'Water %'**
  String get waterPercent;

  /// Muscle percentage column header
  ///
  /// In en, this message translates to:
  /// **'Muscle %'**
  String get musclePercent;

  /// Statistics period selector
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Statistics period selector
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Statistics period selector
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Statistics card label
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// Statistics card label
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// Statistics card label for last value
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// Statistics card label for change value
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Statistics card label for measurement count
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// Empty insights state
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// Insights card title
  ///
  /// In en, this message translates to:
  /// **'Monthly change'**
  String get monthlyChange;

  /// Insights card title
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// Insights card title
  ///
  /// In en, this message translates to:
  /// **'Most active day'**
  String get mostActiveDay;

  /// Insights card title
  ///
  /// In en, this message translates to:
  /// **'Goal progress'**
  String get goalProgress;

  /// Insights card title
  ///
  /// In en, this message translates to:
  /// **'Average weekly weigh-ins'**
  String get avgWeeklyWeighIns;

  /// Insights card title
  ///
  /// In en, this message translates to:
  /// **'Last measurement'**
  String get lastMeasurement;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Unit for streak days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Unit for average weekly count
  ///
  /// In en, this message translates to:
  /// **'per week'**
  String get perWeek;

  /// Monthly weight change display
  ///
  /// In en, this message translates to:
  /// **'{value} kg this month'**
  String kgThisMonth(String value);

  /// Goal progress placeholder
  ///
  /// In en, this message translates to:
  /// **'Set a goal in user settings'**
  String get setGoalInUserSettings;

  /// Streak display with day count
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// Average weekly count display
  ///
  /// In en, this message translates to:
  /// **'{count} per week'**
  String avgWeeklyCount(String count);

  /// Measurement detail screen title
  ///
  /// In en, this message translates to:
  /// **'Measurement'**
  String get measurement;

  /// Error when measurement ID is invalid
  ///
  /// In en, this message translates to:
  /// **'Measurement not found'**
  String get measurementNotFound;

  /// Label for date and time field
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// Confirm dialog title for deleting measurement
  ///
  /// In en, this message translates to:
  /// **'Delete measurement'**
  String get deleteMeasurement;

  /// Warning about irreversible action
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// Save button label
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Comment field label
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// Save measurement button label
  ///
  /// In en, this message translates to:
  /// **'Save measurement'**
  String get saveMeasurement;

  /// Validation error for weight input
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight'**
  String get enterValidWeight;

  /// Edit action label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete action label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Confirm dialog title for deleting user
  ///
  /// In en, this message translates to:
  /// **'Delete user'**
  String get deleteUser;

  /// Confirm dialog message for deleting user
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" and all their data?'**
  String deleteUserNameData(String name);

  /// Dialog title for editing user
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get editUser;

  /// Dialog title for adding user
  ///
  /// In en, this message translates to:
  /// **'Add user'**
  String get addUser;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Height input field label
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightCm;

  /// Goal weight input field label
  ///
  /// In en, this message translates to:
  /// **'Goal weight (kg)'**
  String get goalWeightKg;

  /// Birthday field label
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Bluetooth scanning in progress
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// Bluetooth scan button
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// Bluetooth disconnect button
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Bluetooth status when no device
  ///
  /// In en, this message translates to:
  /// **'No device connected'**
  String get noDeviceConnected;

  /// Bluetooth status subtitle
  ///
  /// In en, this message translates to:
  /// **'Scan for nearby BLE scales'**
  String get scanNearbyBle;

  /// Bluetooth search status
  ///
  /// In en, this message translates to:
  /// **'Searching for devices...'**
  String get searchingForDevices;

  /// Bluetooth empty state
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get noDevicesFound;

  /// Unknown device name
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Bluetooth connect button
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Export section header
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Export CSV menu item
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get exportCsv;

  /// Export CSV subtitle
  ///
  /// In en, this message translates to:
  /// **'Export measurements to CSV file'**
  String get exportMeasurementsCsv;

  /// Import CSV menu item
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get importCsv;

  /// Import CSV subtitle
  ///
  /// In en, this message translates to:
  /// **'Import measurements from CSV file'**
  String get importMeasurementsCsv;

  /// Backup section header
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// Backup database menu item
  ///
  /// In en, this message translates to:
  /// **'Backup database'**
  String get backupDatabase;

  /// Backup database subtitle
  ///
  /// In en, this message translates to:
  /// **'Save a copy of the database'**
  String get saveDatabaseCopy;

  /// Restore database menu item
  ///
  /// In en, this message translates to:
  /// **'Restore database'**
  String get restoreDatabase;

  /// Restore database subtitle
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup file'**
  String get restoreFromBackup;

  /// Danger zone section header
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZone;

  /// Clear data button
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllData;

  /// Clear data subtitle
  ///
  /// In en, this message translates to:
  /// **'Delete all measurements for all users'**
  String get deleteAllMeasurementsAllUsers;

  /// Confirmation message for clearing all data
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all measurements for all users. This cannot be undone.'**
  String get clearDataWarning;

  /// Snackbar after data cleared
  ///
  /// In en, this message translates to:
  /// **'All data cleared'**
  String get allDataCleared;

  /// Snackbar after export
  ///
  /// In en, this message translates to:
  /// **'CSV export initiated'**
  String get csvExportInitiated;

  /// Snackbar after import
  ///
  /// In en, this message translates to:
  /// **'CSV import initiated'**
  String get csvImportInitiated;

  /// Snackbar after backup
  ///
  /// In en, this message translates to:
  /// **'Backup initiated'**
  String get backupInitiated;

  /// Snackbar after restore
  ///
  /// In en, this message translates to:
  /// **'Restore initiated'**
  String get restoreInitiated;

  /// Confirm button label
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Date range selector - all time
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Fat measurement type
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// Water measurement type
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// Muscle measurement type
  ///
  /// In en, this message translates to:
  /// **'Muscle'**
  String get muscle;

  /// Lean Body Mass measurement type
  ///
  /// In en, this message translates to:
  /// **'LBM'**
  String get lbm;

  /// Bone measurement type
  ///
  /// In en, this message translates to:
  /// **'Bone'**
  String get bone;

  /// Waist measurement type
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// Visceral fat measurement type
  ///
  /// In en, this message translates to:
  /// **'Visceral'**
  String get visceral;

  /// Kilogram unit abbreviation
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
