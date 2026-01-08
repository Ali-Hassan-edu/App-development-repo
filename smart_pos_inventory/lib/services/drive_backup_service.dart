import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DriveBackupService {
  static const String folderName = 'SmartPOS Backups';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      // Visible folder + files created by app
      drive.DriveApi.driveFileScope,
    ],
  );

  GoogleSignInAccount? _account;

  Future<GoogleSignInAccount?> signIn() async {
    _account = await _googleSignIn.signIn();
    return _account;
  }

  Future<void> signOut() => _googleSignIn.signOut();

  Future<bool> get isSignedIn async => (await _googleSignIn.isSignedIn());

  Future<drive.DriveApi> _api() async {
    final acc = _account ?? await _googleSignIn.signInSilently();
    if (acc == null) {
      throw Exception('Google Drive not connected');
    }
    _account = acc;

    final authHeaders = await acc.authHeaders;
    final client = _GoogleAuthClient(authHeaders);
    return drive.DriveApi(client);
  }

  Future<String> _ensureFolder(drive.DriveApi api) async {
    final q = "name='$folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
    final res = await api.files.list(q: q, spaces: 'drive', $fields: 'files(id,name)');
    if ((res.files ?? []).isNotEmpty) {
      return res.files!.first.id!;
    }

    final folder = drive.File()
      ..name = folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await api.files.create(folder, $fields: 'id');
    if (created.id == null) throw Exception('Failed to create Drive folder');
    return created.id!;
  }

  Future<String> uploadBackupFile({
    required File localFile,
    String? driveFileName,
  }) async {
    final api = await _api();
    final folderId = await _ensureFolder(api);

    final name = driveFileName ?? localFile.uri.pathSegments.last;

    final driveFile = drive.File()
      ..name = name
      ..parents = [folderId];

    final media = drive.Media(localFile.openRead(), await localFile.length());

    final created = await api.files.create(
      driveFile,
      uploadMedia: media,
      $fields: 'id,name',
    );

    return created.id ?? '';
  }

  Future<List<drive.File>> listBackups() async {
    final api = await _api();
    final folderId = await _ensureFolder(api);

    final q = "'$folderId' in parents and trashed=false";
    final res = await api.files.list(
      q: q,
      orderBy: 'modifiedTime desc',
      $fields: 'files(id,name,modifiedTime,size)',
    );

    return res.files ?? [];
  }

  /// Downloads a drive file into temp folder and returns the downloaded File.
  Future<File> downloadBackup(String driveFileId, String fileName) async {
    final api = await _api();
    final dir = await getTemporaryDirectory();
    final outFile = File('${dir.path}/$fileName');

    final media = await api.files.get(
      driveFileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    );

    if (media is! drive.Media) throw Exception('Failed to download file');

    final sink = outFile.openWrite();
    await media.stream.pipe(sink);
    await sink.flush();
    await sink.close();

    return outFile;
  }

  /// ✅ Delete a backup file from Drive
  Future<void> deleteDriveFile(String fileId) async {
    final api = await _api();
    await api.files.delete(fileId);
  }

  /// ✅ Returns a web URL for opening the backup folder in browser/app
  Future<String> getFolderWebUrl() async {
    final api = await _api();
    final folderId = await _ensureFolder(api);
    return 'https://drive.google.com/drive/folders/$folderId';
  }
}

/// Minimal auth client for googleapis
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }
}
