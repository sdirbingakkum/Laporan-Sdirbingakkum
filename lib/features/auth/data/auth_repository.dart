import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _puspomadEmailDomain = '@puspomad.mil.id';

String _emailFromUsername(String username) {
  final normalized = username.trim();
  final atIndex = normalized.indexOf('@');
  final baseUsername = atIndex >= 0
      ? normalized.substring(0, atIndex)
      : normalized;
  return '$baseUsername$_puspomadEmailDomain';
}

class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient _client;

  Future<AuthResponse> signIn({
    required String username,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: _emailFromUsername(username),
      password: password,
    );
  }

  Future<void> signOut() {
    return _client.auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});
