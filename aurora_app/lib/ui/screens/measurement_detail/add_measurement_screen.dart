import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:openscale/core/bloc/measurement/measurement_bloc.dart';

class AddMeasurementScreen extends StatefulWidget {
  const AddMeasurementScreen({super.key});

  @override
  State<AddMeasurementScreen> createState() => _AddMeasurementScreenState();
}

class _AddMeasurementScreenState extends State<AddMeasurementScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _commentController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _commentController = TextEditingController();
    _selectedDateTime = DateTime.now();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.addMeasurement),
        actions: [
          TextButton(
            onPressed: _onSave,
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(AppLocalizations.of(context)!.dateTime),
              subtitle: Text(
                DateFormat.yMd().add_Hm().format(_selectedDateTime),
              ),
              onTap: () async {
                final picked = await _pickDateTime(context);
                if (picked != null) {
                  setState(() {
                    _selectedDateTime = picked;
                  });
                }
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.weight,
                  suffixText: AppLocalizations.of(context)!.kg,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.comment,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _onSave,
            child: Text(AppLocalizations.of(context)!.saveMeasurement),
          ),
        ],
      ),
    );
  }

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date == null) return null;

    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _onSave() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterValidWeight)),
      );
      return;
    }

    context.read<MeasurementBloc>().add(
      AddMeasurement(
        dateTime: _selectedDateTime,
        weight: weight,
        comment: _commentController.text.trim(),
      ),
    );
    context.pop();
  }
}
