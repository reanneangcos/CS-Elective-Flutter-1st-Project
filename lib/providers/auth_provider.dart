import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Holds who is signed in and exposes the sign-in options:
/// email + password, and GitHub (the additional third-party provider).
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._auth) {
    _user = _auth.currentUser;
    _sub = _auth.onAuthStateChange.listen(
      (state) {
        _user = state.session?.user;
        busy = false;
        if (_user != null) error = null;
        notifyListeners();
      },
      // e.g. the user cancelled on GitHub and was redirected back with an error
      onError: (Object e) {
        busy = false;
        error = _describe(e);
        notifyListeners();
      },
    );
  }

  final GoTrueClient _auth;
  late final StreamSubscription<AuthState> _sub;

  User? _user;
  User? get user => _user;
  bool get isSignedIn => _user != null;

  bool busy = false;
  String? error;
  String? info;

  /// Where Supabase sends the user back to after GitHub (or an email
  /// confirmation link). Must be listed under Authentication → URL
  /// Configuration → Redirect URLs in the Supabase dashboard.
  static String get redirectUrl =>
      kIsWeb ? Uri.base.origin : 'com.courtsidekits.app://login-callback';

  // ---------------- email + password ----------------

  Future<void> signInWithEmail(String email, String password) => _run(() async {
        await _auth.signInWithPassword(email: email.trim(), password: password);
      });

  Future<void> signUpWithEmail(String email, String password) => _run(() async {
        final res = await _auth.signUp(
          email: email.trim(),
          password: password,
          emailRedirectTo: redirectUrl,
        );
        if (res.session == null) {
          info = 'Account created! Check ${email.trim()} for a confirmation link, '
              'then sign in.';
        }
      });

  // ---------------- third-party provider: GitHub ----------------

  /// Opens GitHub's login page. On web this navigates the current tab; on
  /// mobile/desktop it opens the browser and returns through the deep link.
  /// Either way the session arrives through [onAuthStateChange].
  Future<void> signInWithGitHub() => _run(() async {
        await _auth.signInWithOAuth(
          OAuthProvider.github,
          redirectTo: redirectUrl,
        );
      }, keepBusy: true);

  Future<void> signOut() => _run(() => _auth.signOut());

  void clearMessages() {
    error = null;
    info = null;
    notifyListeners();
  }

  // ---------------- profile info for the UI ----------------

  /// 'email' or 'github'
  String get provider => (_user?.appMetadata['provider'] as String?) ?? 'email';

  String get displayName {
    final meta = _user?.userMetadata ?? const {};
    return (meta['full_name'] ?? meta['user_name'] ?? meta['name'] ?? _user?.email ?? 'Signed in')
        .toString();
  }

  String? get avatarUrl => _user?.userMetadata?['avatar_url'] as String?;

  // ---------------- internals ----------------

  Future<void> _run(Future<void> Function() action, {bool keepBusy = false}) async {
    busy = true;
    error = null;
    info = null;
    notifyListeners();
    try {
      await action();
      // OAuth leaves the app to finish on GitHub, so stay busy until the
      // auth state changes (or the user comes back and tries again).
      if (!keepBusy) busy = false;
    } catch (e) {
      busy = false;
      error = _describe(e);
    }
    notifyListeners();
  }

  String _describe(Object e) => e is AuthException ? e.message : 'Something went wrong: $e';

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
