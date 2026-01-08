import 'package:flutter/widgets.dart';

import 'backup_service.dart';

class AppLifecycleBackup with WidgetsBindingObserver {
  final BackupService _backupService;

  AppLifecycleBackup(this._backupService);

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Runs when app goes background / minimized
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      try {
        await _backupService.autoBackupIfNeeded();
      } catch (_) {
        // ignore errors silently
      }
    }
  }
}
