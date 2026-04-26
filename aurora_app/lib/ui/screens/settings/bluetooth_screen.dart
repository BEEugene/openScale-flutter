import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openscale/l10n/app_localizations.dart';

import 'package:openscale/core/bloc/bluetooth/bluetooth_bloc.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BluetoothBloc>().add(const StartScan());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(AppLocalizations.of(context)!.bluetooth)),
          body: Column(
            children: [
              _ConnectionStatusCard(state: state),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: state.isScanning
                            ? null
                            : () => context.read<BluetoothBloc>().add(
                                const StartScan(),
                              ),
                        icon: Icon(
                          state.isScanning
                              ? Icons.hourglass_empty
                              : Icons.search,
                        ),
                        label: Text(
                          state.isScanning
                              ? AppLocalizations.of(context)!.scanning
                              : AppLocalizations.of(context)!.scan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (state.connectedDevice != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.read<BluetoothBloc>().add(
                            const Disconnect(),
                          ),
                          icon: const Icon(Icons.bluetooth_disabled),
                          label: Text(AppLocalizations.of(context)!.disconnect),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(child: _DeviceList(state: state)),
            ],
          ),
        );
      },
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  final BluetoothState state;

  const _ConnectionStatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.connectedDevice == null) {
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: ListTile(
          leading: Icon(
            Icons.bluetooth_disabled,
            color: Theme.of(context).colorScheme.outline,
          ),
          title: Text(AppLocalizations.of(context)!.noDeviceConnected),
          subtitle: Text(AppLocalizations.of(context)!.scanNearbyBle),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.bluetooth_connected),
        title: Text(state.connectedDevice!.name),
        subtitle: Text(state.connectedDevice!.id),
      ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  final BluetoothState state;

  const _DeviceList({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.discoveredDevices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 8),
            Text(
              state.isScanning
                  ? AppLocalizations.of(context)!.searchingForDevices
                  : AppLocalizations.of(context)!.noDevicesFound,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.discoveredDevices.length,
      itemBuilder: (context, index) {
        final device = state.discoveredDevices[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.bluetooth),
            title: Text(
              device.name.isNotEmpty
                  ? device.name
                  : AppLocalizations.of(context)!.unknown,
            ),
            subtitle: Text('${device.id} · ${device.rssi} dBm'),
            trailing: FilledButton.tonal(
              onPressed: () =>
                  context.read<BluetoothBloc>().add(Connect(device.id)),
              child: Text(AppLocalizations.of(context)!.connect),
            ),
          ),
        );
      },
    );
  }
}
