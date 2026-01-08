import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/backup_service.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _loading = false;
  String? _error;
  List<File> _files = [];

  @override
  void initState() {
    super.initState();
    _load();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            const SizedBox(height: 30),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 30),
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
            Text(
              'No backups found.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),

          ..._files.map((f) {
            final name = f.path.split('/').last;
            final time = f.lastModifiedSync();

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
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
                        Text(
                          'Modified: $time',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
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
