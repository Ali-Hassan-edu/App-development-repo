import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:path_provider/path_provider.dart';

import 'drive_auth.dart';

class DriveBackupService {
  DriveBackupService._();
  static final DriveBackupService instance = DriveBackupService._();

  static const String folderName = 'SmartPOS Backups';

  Future<drive.DriveApi> _api() async {
    final client = await DriveAuth.instance.getAuthClient();
    return drive.DriveApi(client);
  }

  Future<String> _ensureFolderId() async {
    final api = await _api();

    // Find folder by name
    final res = await api.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$folderName' and trashed=false",
      $fields: "files(id,name)",
      spaces: 'drive',
    );

    if (res.files != null && res.files!.isNotEmpty) {
      return res.files!.first.id!;
    }

    // Create folder
    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await api.files.create(folder, $fields: 'id');
    return created.id!;
  }

  Future<String> uploadBackupFile({
    required String localPath,
    String? remoteName,
  }) async {
    final api = await _api();
    final folderId = await _ensureFolderId();

    final file = File(localPath);
    if (!await file.exists()) throw 'Local backup not found';

    final name = remoteName ?? file.uri.pathSegments.last;

    final media = drive.Media(file.openRead(), await file.length());

    final gFile = drive.File()
      ..name = name
      ..parents = [folderId];

    final created = await api.files.create(
      gFile,
      uploadMedia: media,
      $fields: 'id,name',
    );

    return created.id!;
  }

  Future<List<drive.File>> listBackups() async {
    final api = await _api();
    final folderId = await _ensureFolderId();

    final res = await api.files.list(
      q: "'$folderId' in parents and trashed=false",
      orderBy: 'modifiedTime desc',
      $fields: "files(id,name,size,modifiedTime)",
      spaces: 'drive',
    );

    return res.files ?? [];
  }

  Future<String> downloadBackupToTemp(String fileId) async {
    final api = await _api();
    final tmpDir = await getTemporaryDirectory();

    final meta = await api.files.get(fileId, $fields: 'name') as drive.File;
    final name = meta.name ?? 'backup.zip';

    final outFile = File('${tmpDir.path}/$name');

    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final sink = outFile.openWrite();
    await media.stream.pipe(sink);
    await sink.flush();
    await sink.close();

    return outFile.path;
  }

  Future<void> deleteBackup(String fileId) async {
    final api = await _api();
    await api.files.delete(fileId);
  }
}
