import 'dart:io';

import 'package:flutter/material.dart';
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
  List<dynamic> _driveFiles = []; // drive.File list (kept dynamic to avoid extra import)

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
    } catch (_) {
      // ignore
    }
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
  // ✅ GOOGLE DRIVE (REAL)
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Drive connected')),
      );

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

  /// ✅ Upload latest existing local backup file to Drive
  Future<void> _uploadLatestToDrive() async {
    if (!_driveConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect Google Drive first')),
      );
      return;
    }
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No local backups to upload')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final latest = _files.reduce((a, b) =>
      a.lastModifiedSync().isAfter(b.lastModifiedSync()) ? a : b);

      final driveSvc = context.read<DriveBackupService>();
      await driveSvc.uploadBackupFile(localFile: latest);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded: ${latest.path.split('/').last}')),
      );

      await _loadDriveFiles();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  /// ✅ Create a new local backup first, then upload that file
  Future<void> _uploadNowToDrive() async {
    if (!_driveConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect Google Drive first')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploaded: ${file.path.split('/').last}')),
      );

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restored from Google Drive')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted from Drive: $name')),
      );

      await _loadDriveFiles();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  Future<void> _openDriveFolder() async {
    if (!_driveConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect Google Drive first')),
      );
      return;
    }

    try {
      final driveSvc = context.read<DriveBackupService>();
      final url = await driveSvc.getFolderWebUrl();

      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Drive folder')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = isDark ? const Color(0xFF161E35) : Colors.white;
    final border = isDark ? Colors.white12 : Colors.black12;
    final sub = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
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
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ GOOGLE DRIVE SECTION
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud, color: Color(0xFF3CC5FF)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Google Drive Backup (Visible Folder)',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _driveConnected
                            ? const Color(0xFF00C9A7).withOpacity(0.18)
                            : Colors.orange.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _driveConnected ? const Color(0xFF00C9A7) : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _driveConnected ? 'Connected' : 'Not Connected',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _driveConnected ? const Color(0xFF00C9A7) : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Backups will be stored in: Google Drive → "${DriveBackupService.folderName}"',
                  style: TextStyle(color: sub, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

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
                      ),
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
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text('Drive Backups (${_driveFiles.length})',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),

                if (_driveConnected && _driveFiles.isEmpty)
                  Text('No Drive backups yet.', style: TextStyle(color: sub, fontWeight: FontWeight.w700)),

                if (_driveConnected)
                  ..._driveFiles.take(8).map((f) {
                    final name = (f.name ?? '').toString();
                    final modified = (f.modifiedTime?.toLocal().toString() ?? '');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
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
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                                const SizedBox(height: 2),
                                Text('Modified: $modified',
                                    style: TextStyle(color: sub, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Restore',
                            onPressed: _loading ? null : () => _restoreFromDrive(f),
                            icon: const Icon(Icons.restore),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: _loading ? null : () => _deleteFromDrive(f),
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ✅ LOCAL BACKUP BUTTON
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _manualBackup,
              icon: const Icon(Icons.save),
              label: const Text('Create Backup Now', style: TextStyle(fontWeight: FontWeight.w900)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3CC5FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 14),

          if (_loading) ...[
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
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
          Text('Local Backups (${_files.length})', style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),

          if (!_loading && _files.isEmpty)
            Text('No backups found.', style: TextStyle(color: sub, fontWeight: FontWeight.w700)),

          ..._files.map((f) {
            final name = f.path.split('/').last;
            final time = f.lastModifiedSync();

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
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
                        const SizedBox(height: 2),
                        Text('Modified: $time', style: TextStyle(fontWeight: FontWeight.w700, color: sub)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Restore',
                    onPressed: _loading ? null : () => _restore(f),
                    icon: const Icon(Icons.restore),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: _loading ? null : () => _delete(f),
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
