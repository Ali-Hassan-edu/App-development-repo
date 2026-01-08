import 'package:flutter/widgets.dart';
import 'backup_service.dart';


class BackupLifecycleObserver with WidgetsBindingObserver {
  final BackupService _backupService = BackupService();

  void start() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _backupService.autoBackupIfNeeded();
    }
  }
}
