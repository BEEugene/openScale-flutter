import 'package:logging/logging.dart';

void setupLogging({Level level = Level.INFO}) {
  hierarchicalLoggingEnabled = true;
  Logger.root.level = level;
}

Logger createLogger(String name) => Logger(name);
