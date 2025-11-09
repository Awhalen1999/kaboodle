import 'package:kaboodle_app/models/user.dart';

/// State class for managing user data
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  /// Create a copy of this state with some fields replaced
  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Helper to check if user data is loaded
  bool get hasUser => user != null && !isLoading;

  /// Helper to check if we're ready to display (no loading, no error)
  bool get isReady => !isLoading && error == null;
}
