import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';

import 'package:openscale/core/bloc/user/user_bloc.dart';
import 'package:openscale/core/models/user.dart';
import 'package:openscale/ui/widgets/dialogs/confirm_dialog.dart';
import 'package:openscale/ui/widgets/dialogs/date_time_picker_dialog.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.users)),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.users.length,
            itemBuilder: (context, index) {
              final user = state.users[index];
              final isSelected = user.id == state.selectedUser?.id;
              return Card(
                color: isSelected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${user.bodyHeight} cm · ${user.goalWeight} kg',
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, size: 20)
                      : null,
                  onTap: () =>
                      context.read<UserBloc>().add(SelectUser(user.id)),
                  onLongPress: () => _showUserOptions(context, user),
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddUserDialog(context),
            child: const Icon(Icons.person_add),
          ),
        );
      },
    );
  }

  void _showAddUserDialog(BuildContext context) {
    _showUserFormDialog(context, isEdit: false);
  }

  void _showUserOptions(BuildContext context, User user) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.edit),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showUserFormDialog(context, user: user, isEdit: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.delete),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showConfirmDialog(
                    context: context,
                    title: l10n.deleteUser,
                    message: l10n.deleteUserNameData(user.name),
                    isDestructive: true,
                    onConfirm: () {
                      context.read<UserBloc>().add(DeleteUser(user.id));
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserFormDialog(
    BuildContext context, {
    User? user,
    required bool isEdit,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _UserFormDialog(user: user, isEdit: isEdit),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final User? user;
  final bool isEdit;

  const _UserFormDialog({this.user, required this.isEdit});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _goalWeightController;
  late DateTime _birthday;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.isEdit ? widget.user?.name ?? '' : '',
    );
    _heightController = TextEditingController(
      text: widget.isEdit ? widget.user?.bodyHeight.toString() : '',
    );
    _goalWeightController = TextEditingController(
      text: widget.isEdit ? widget.user?.goalWeight.toString() : '',
    );
    _birthday = widget.isEdit
        ? widget.user?.birthday ?? DateTime(1990)
        : DateTime(1990);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEdit
            ? AppLocalizations.of(context)!.editUser
            : AppLocalizations.of(context)!.addUser,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.name,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.heightCm,
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _goalWeightController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.goalWeightKg,
                border: const OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppLocalizations.of(context)!.birthday),
              subtitle: Text(
                '${_birthday.day}.${_birthday.month}.${_birthday.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDateTimePickerDialog(
                  context: context,
                  initialDate: _birthday,
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _birthday = picked;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: _onSave,
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  void _onSave() {
    final name = _nameController.text.trim();
    final height = double.tryParse(_heightController.text) ?? 170;
    final goalWeight = double.tryParse(_goalWeightController.text) ?? 70;

    if (name.isEmpty) return;

    if (widget.isEdit) {
      context.read<UserBloc>().add(
        UpdateUser(
          id: widget.user?.id ?? '',
          name: name,
          height: height,
          goalWeight: goalWeight,
          birthday: _birthday,
        ),
      );
    } else {
      context.read<UserBloc>().add(
        AddUser(
          name: name,
          height: height,
          goalWeight: goalWeight,
          birthday: _birthday,
        ),
      );
    }
    Navigator.pop(context);
  }
}
