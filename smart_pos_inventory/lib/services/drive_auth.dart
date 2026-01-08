import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// Simple HTTP client that injects Google auth headers for googleapis.
class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

class DriveAuth {
  DriveAuth._();

  static final DriveAuth instance = DriveAuth._();

  // ✅ Scope: user selects a file/folder created by this app ("drive.file")
  // (Enough for creating/uploading backup files)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<GoogleAuthClient> getAuthClient() async {
    final user = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (user == null) {
      throw 'Google Sign-In required';
    }

    final headers = await user.authHeaders;
    return GoogleAuthClient(headers);
  }
}
