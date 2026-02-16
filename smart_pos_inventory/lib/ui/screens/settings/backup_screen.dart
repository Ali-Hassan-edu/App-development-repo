import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/backup_service.dart';
import '../../../services/drive_backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _loading = false;
  String? _error;

  List<File> _files = [];

  bool _driveConnected = false;
  List<dynamic> _driveFiles = [];

  @override
  void initState() {
    super.initState();
    _load();
    _checkDrive();
  }

  Future<void> _checkDrive() async {
    try {
      final driveSvc = context.read<DriveBackupService>();
      final ok = await driveSvc.isSignedIn;
      setState(() => _driveConnected = ok);
      if (ok) await _loadDriveFiles();
    } catch (_) {}
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<BackupService>();
      final list = await service.listLocalBackups();
      setState(() => _files = list);
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _manualBackup() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<BackupService>();
      final path = await service.createLocalBackup(reason: 'manual');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup created: ${path.split('/').last}')),
      );
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _restore(File f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore Backup'),
        content: Text(
          'This will REPLACE your current data with:\n\n${f.path.split('/').last}\n\nContinue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<BackupService>();
      await service.restoreFromBackupFile(f.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup restored successfully')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _delete(File f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Backup'),
        content: Text('Delete this backup?\n\n${f.path.split('/').last}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = context.read<BackupService>();
      await service.deleteBackupFile(f.path);
      await _load();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  // ----------------------------
  // GOOGLE DRIVE
  // ----------------------------

  Future<void> _connectDrive() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final driveSvc = context.read<DriveBackupService>();
      final acc = await driveSvc.signIn();
      if (acc == null) throw Exception('Google sign-in cancelled');

      setState(() => _driveConnected = true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Drive connected')));
      await _loadDriveFiles();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _loadDriveFiles() async {
    try {
      final driveSvc = context.read<DriveBackupService>();
      final list = await driveSvc.listBackups();
      setState(() => _driveFiles = list);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _uploadLatestToDrive() async {
    if (!_driveConnected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connect Google Drive first')));
      return;
    }
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No local backups to upload')));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final latest = _files.reduce(
            (a, b) => a.lastModifiedSync().isAfter(b.lastModifiedSync()) ? a : b,
      );

      final driveSvc = context.read<DriveBackupService>();
      await driveSvc.uploadBackupFile(localFile: latest);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded: ${latest.path.split('/').last}')));

      await _loadDriveFiles();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _uploadNowToDrive() async {
    if (!_driveConnected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connect Google Drive first')));
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final backupSvc = context.read<BackupService>();
      final path = await backupSvc.createLocalBackup(reason: 'manual_drive');
      final file = File(path);

      final driveSvc = context.read<DriveBackupService>();
      await driveSvc.uploadBackupFile(localFile: file);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uploaded: ${file.path.split('/').last}')));

      await _load();
      await _loadDriveFiles();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _restoreFromDrive(dynamic f) async {
    final fileId = (f.id ?? '').toString();
    final name = (f.name ?? 'backup.json').toString();
    if (fileId.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restore From Google Drive'),
        content: Text('Restore this backup?\n\n$name'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final driveSvc = context.read<DriveBackupService>();
      final downloaded = await driveSvc.downloadBackup(fileId, name);

      final local = context.read<BackupService>();
      await local.restoreFromBackupFile(downloaded.path);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restored from Google Drive')));
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _deleteFromDrive(dynamic f) async {
    final fileId = (f.id ?? '').toString();
    final name = (f.name ?? '').toString();
    if (fileId.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete From Drive'),
        content: Text('Delete this Drive backup?\n\n$name'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final driveSvc = context.read<DriveBackupService>();
      await driveSvc.deleteDriveFile(fileId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted from Drive: $name')));

      await _loadDriveFiles();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _openDriveFolder() async {
    if (!_driveConnected) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connect Google Drive first')));
      return;
    }

    try {
      final driveSvc = context.read<DriveBackupService>();
      final url = await driveSvc.getFolderWebUrl();

      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open Drive folder')));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F1320) : const Color(0xFFF6F7FB);
    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final text = isDark ? Colors.white : Colors.black87;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Backup', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: _loading
                ? null
                : () async {
              await _load();
              if (_driveConnected) await _loadDriveFiles();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        children: [
          _headerChip(
            icon: Icons.cloud,
            title: 'Google Drive',
            value: _driveConnected ? 'Connected' : 'Not Connected',
            ok: _driveConnected,
          ).animate().fadeIn(duration: 240.ms).slideY(begin: .08),

          const SizedBox(height: 10),

          _card(
            card: card,
            border: border,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backups saved to: Google Drive → "${DriveBackupService.folderName}"',
                  style: TextStyle(color: sub, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _connectDrive,
                        icon: const Icon(Icons.login),
                        label: const Text('Connect', style: TextStyle(fontWeight: FontWeight.w900)),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _openDriveFolder,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Open Folder', style: TextStyle(fontWeight: FontWeight.w900)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6D5DF6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _uploadNowToDrive,
                        icon: const Icon(Icons.cloud_done),
                        label: const Text('Upload Now', style: TextStyle(fontWeight: FontWeight.w900)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C9A7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ).animate().scale(begin: const Offset(.98, .98)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _uploadLatestToDrive,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Upload Latest', style: TextStyle(fontWeight: FontWeight.w900)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3CC5FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ).animate().scale(begin: const Offset(.98, .98)),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Text('Drive Backups (${_driveFiles.length})', style: TextStyle(fontWeight: FontWeight.w900, color: text)),
                const SizedBox(height: 8),

                if (_driveConnected && _driveFiles.isEmpty)
                  Text('No Drive backups yet.', style: TextStyle(color: sub, fontWeight: FontWeight.w700)),

                if (_driveConnected)
                  ..._driveFiles.take(8).map((f) {
                    final name = (f.name ?? '').toString();
                    final modified = (f.modifiedTime?.toLocal().toString() ?? '');

                    return _miniFileRow(
                      border: border,
                      sub: sub,
                      title: name,
                      subtitle: 'Modified: $modified',
                      onRestore: _loading ? null : () => _restoreFromDrive(f),
                      onDelete: _loading ? null : () => _deleteFromDrive(f),
                    );
                  }),
              ],
            ),
          ).animate().fadeIn(duration: 320.ms).slideY(begin: .06),

          const SizedBox(height: 14),

          _headerChip(
            icon: Icons.save,
            title: 'Local Backup',
            value: '${_files.length} files',
            ok: true,
          ).animate().fadeIn(duration: 240.ms).slideY(begin: .06),

          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _manualBackup,
              icon: const Icon(Icons.add),
              label: const Text('Create Backup Now', style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CC5FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ).animate().fadeIn(duration: 320.ms).slideY(begin: .05),

          const SizedBox(height: 14),

          if (_loading) ...[
            const SizedBox(height: 10),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
          ],

          if (_error != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEAEA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
              ),
              child: Text(_error!, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),

          const SizedBox(height: 10),
          Text('Local Backups', style: TextStyle(fontWeight: FontWeight.w900, color: text)),
          const SizedBox(height: 8),

          if (!_loading && _files.isEmpty)
            Text('No backups found.', style: TextStyle(color: sub, fontWeight: FontWeight.w700)),

          ..._files.map((f) {
            final name = f.path.split('/').last;
            final time = f.lastModifiedSync();

            return _miniFileRow(
              border: border,
              sub: sub,
              title: name,
              subtitle: 'Modified: $time',
              onRestore: _loading ? null : () => _restore(f),
              onDelete: _loading ? null : () => _delete(f),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _headerChip({
    required IconData icon,
    required String title,
    required String value,
    required bool ok,
  }) {
    final c = ok ? const Color(0xFF00C9A7) : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: c.withOpacity(0.14),
        border: Border.all(color: c.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: c),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, color: c)),
        ],
      ),
    );
  }

  Widget _card({required Color card, required Color border, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _miniFileRow({
    required Color border,
    required Color sub,
    required String title,
    required String subtitle,
    required VoidCallback? onRestore,
    required VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Restore',
            onPressed: onRestore,
            icon: const Icon(Icons.restore),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 220.ms).slideX(begin: .05);
  }
}
