import 'package:flutter/material.dart';
import 'package:openscale/l10n/app_localizations.dart';

import 'package:openscale/ui/widgets/dialogs/confirm_dialog.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.dataManagement)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    l10n.export,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: Text(l10n.exportCsv),
                  subtitle: Text(l10n.exportMeasurementsCsv),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.csvExportInitiated)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined),
                  title: Text(l10n.importCsv),
                  subtitle: Text(l10n.importMeasurementsCsv),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.csvImportInitiated)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    l10n.backup,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.save_outlined),
                  title: Text(l10n.backupDatabase),
                  subtitle: Text(l10n.saveDatabaseCopy),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.backupInitiated)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restore_outlined),
                  title: Text(l10n.restoreDatabase),
                  subtitle: Text(l10n.restoreFromBackup),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.restoreInitiated)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    l10n.dangerZone,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    l10n.clearAllData,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: Text(l10n.deleteAllMeasurementsAllUsers),
                  onTap: () => showConfirmDialog(
                    context: context,
                    title: l10n.clearAllData,
                    message: l10n.clearDataWarning,
                    isDestructive: true,
                    onConfirm: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.allDataCleared)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
