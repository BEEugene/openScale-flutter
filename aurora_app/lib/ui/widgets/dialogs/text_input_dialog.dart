import 'package:flutter/material.dart';
import 'package:openscale/l10n/app_localizations.dart';

Future<String?> showTextInputDialog({
  required BuildContext context,
  required String title,
  String initialValue = '',
  String hint = '',
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint.isNotEmpty ? hint : null,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext, controller.text.trim());
            },
            child: Text(l10n.ok),
          ),
        ],
      );
    },
  );
}
