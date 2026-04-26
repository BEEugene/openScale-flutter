import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

abstract class BackupService {
  Future<String> exportDatabase(String destDir);
  Future<String> importDatabase(String sourcePath);
}

abstract class FileService {
  Future<bool> exists(String path);
  Future<List<int>> readBytes(String path);
  Future<void> writeBytes(String path, List<int> bytes);
  Future<void> copy(String sourcePath, String destPath);
}

class FileBackupService implements BackupService {
  final Database _database;
  final FileService _fileService;

  FileBackupService(this._database, this._fileService);

  @override
  Future<String> exportDatabase(String destDir) async {
    final dbPath = _database.path;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFileName = 'openscale_backup_$timestamp.db';
    final destPath = p.join(destDir, backupFileName);

    await _fileService.copy(dbPath, destPath);

    return destPath;
  }

  @override
  Future<String> importDatabase(String sourcePath) async {
    final dbPath = _database.path;

    if (!await _fileService.exists(sourcePath)) {
      throw StateError('Source backup file not found: $sourcePath');
    }

    await _database.close();

    final bytes = await _fileService.readBytes(sourcePath);
    await _fileService.writeBytes(dbPath, bytes);

    return dbPath;
  }
}
