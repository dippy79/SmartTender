import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }
enum UserRole { superAdmin, admin, user }

class AuthProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;

  AuthStatus _status = AuthStatus.unknown;
  UserRole _role = UserRole.user;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserRole get role => _role;
  User? get user => _user;
  String? get errorMessage => _errorMessage;

  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get isSuperAdmin => _role == UserRole.superAdmin;
  bool get isAdmin => _role == UserRole.admin || _role == UserRole.superAdmin;

  AuthProvider() {
    _init();
    // Listen to auth state changes (auto logout/login)
    _client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _user = data.session?.user;
        _fetchRole();
      } else if (event == AuthChangeEvent.signedOut) {
        _status = AuthStatus.unauthenticated;
        _role = UserRole.user;
        _user = null;
        notifyListeners();
      }
    });
  }

  void _init() {
    final session = _client.auth.currentSession;
    if (session != null) {
      _user = session.user;
      _fetchRole();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<void> _fetchRole() async {
    try {
      final response = await _client
          .from('user_roles')
          .select('role')
          .eq('user_id', _user!.id)
          .maybeSingle();

      final roleStr = response?['role'] as String? ?? 'user';
      _role = _parseRole(roleStr);
      _status = AuthStatus.authenticated;
    } catch (e) {
      debugPrint('Role fetch error: $e');
      _role = UserRole.user;
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  UserRole _parseRole(String role) {
    switch (role) {
      case 'super_admin':
        return UserRole.superAdmin;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    try {
      final res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.session != null) {
        _user = res.session!.user;
        await _fetchRole();
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  void bypassAsSuperAdmin() {
    _role = UserRole.superAdmin;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }
}
