import 'package:flutter/material.dart';
import 'package:openscale/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:openscale/ui/navigation/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          _SettingsSection(
            title: l10n.profile,
            children: [
              ListTile(
                leading: const Icon(Icons.people_outlined),
                title: Text(l10n.users),
                subtitle: Text(l10n.manageUsersAndProfiles),
                onTap: () => context.push(AppRoutes.userManagement),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.connectivity,
            children: [
              ListTile(
                leading: const Icon(Icons.bluetooth_outlined),
                title: Text(l10n.bluetooth),
                subtitle: Text(l10n.connectBleScale),
                onTap: () => context.push(AppRoutes.bluetooth),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.data,
            children: [
              ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: Text(l10n.dataManagement),
                subtitle: Text(l10n.importExportBackup),
                onTap: () => context.push(AppRoutes.dataManagement),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.appearance,
            children: [
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(l10n.theme),
                subtitle: Text(l10n.lightDarkSystem),
              ),
              ListTile(
                leading: const Icon(Icons.straighten_outlined),
                title: Text(l10n.units),
                subtitle: Text(l10n.weightHeight),
              ),
            ],
          ),
          _SettingsSection(
            title: l10n.about,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.aboutOpenScale),
                subtitle: Text(l10n.version('1.0.0')),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.license),
                subtitle: Text(l10n.gplV3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...children,
        const Divider(indent: 16, endIndent: 16),
      ],
    );
  }
}
