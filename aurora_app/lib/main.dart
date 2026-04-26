import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:openscale/l10n/app_localizations.dart';

import 'package:openscale/core/database/app_database.dart';
import 'package:openscale/core/database/dao/user_dao.dart';
import 'package:openscale/core/database/dao/measurement_dao.dart';
import 'package:openscale/core/repository/user_repository_impl.dart';
import 'package:openscale/core/repository/measurement_repository_impl.dart';
import 'package:openscale/core/bloc/user/user_bloc.dart';
import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';
import 'package:openscale/core/bloc/settings/settings_bloc.dart';
import 'package:openscale/core/bloc/bluetooth/bluetooth_bloc.dart';
import 'package:openscale/core/services/ble/ble_interface.dart';
import 'package:openscale/core/services/ble/ble_mock.dart';
import 'package:openscale/core/services/import_export/csv_service.dart';
import 'package:openscale/core/services/backup/backup_service.dart';
import 'package:openscale/core/services/backup/linux_file_service.dart';
import 'package:openscale/ui/theme/app_theme.dart';
import 'package:openscale/ui/navigation/app_router.dart';

final getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setupDependencies();
  runApp(const OpenScaleApp());
}

Future<void> _setupDependencies() async {
  final db = AppDatabase();
  await db.initialize();

  getIt.registerSingleton<AppDatabase>(db);

  final userDao = UserDao(db.database);
  final measurementDao = MeasurementDao(db.database);

  getIt.registerSingleton<UserRepositoryImpl>(UserRepositoryImpl(userDao));
  getIt.registerSingleton<MeasurementRepositoryImpl>(
    MeasurementRepositoryImpl(measurementDao),
  );

  getIt.registerSingleton<CsvService>(CsvService());
  getIt.registerSingleton<FileService>(LinuxFileService());
  getIt.registerSingleton<BackupService>(
    FileBackupService(db.database, getIt<FileService>()),
  );

  getIt.registerLazySingleton<BleService>(BleMock.new);
  getIt.registerLazySingleton<BluetoothBloc>(
    () => BluetoothBloc(getIt<BleService>()),
  );
  getIt.registerLazySingleton<UserBloc>(
    () => UserBloc(getIt<UserRepositoryImpl>()),
  );
  getIt.registerLazySingleton<SettingsBloc>(() => SettingsBloc());
  getIt.registerFactory<MeasurementBloc>(
    () => MeasurementBloc(getIt<MeasurementRepositoryImpl>()),
  );
}

class OpenScaleApp extends StatelessWidget {
  const OpenScaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<UserBloc>()),
        BlocProvider.value(value: getIt<SettingsBloc>()),
        BlocProvider.value(value: getIt<BluetoothBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            title: 'openScale',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale(settings.locale),
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
