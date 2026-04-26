import 'dart:io';

import 'package:openscale/core/services/backup/backup_service.dart';

class LinuxFileService implements FileService {
  @override
  Future<bool> exists(String path) async {
    return File(path).exists();
  }

  @override
  Future<List<int>> readBytes(String path) async {
    return File(path).readAsBytes();
  }

  @override
  Future<void> writeBytes(String path, List<int> bytes) async {
    await File(path).writeAsBytes(bytes);
  }

  @override
  Future<void> copy(String sourcePath, String destPath) async {
    await File(sourcePath).copy(destPath);
  }
}
