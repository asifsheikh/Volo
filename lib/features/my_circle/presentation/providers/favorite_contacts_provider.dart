import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Basic state for the Favorite Contacts screen
class FavoriteContactsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> contacts; // Will be properly typed when we implement the full feature

  const FavoriteContactsState({
    this.isLoading = false,
    this.error,
    this.contacts = const [],
  });

  FavoriteContactsState copyWith({
    bool? isLoading,
    String? error,
    List<dynamic>? contacts,
  }) {
    return FavoriteContactsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      contacts: contacts ?? this.contacts,
    );
  }
}

/// Provider for Favorite Contacts screen state
class FavoriteContactsNotifier extends StateNotifier<FavoriteContactsState> {
  FavoriteContactsNotifier() : super(const FavoriteContactsState());

  /// Load favorite contacts (placeholder for now)
  Future<void> loadContacts() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // TODO: Implement actual contact loading logic
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Add a new contact (placeholder for now)
  Future<void> addContact() async {
    // TODO: Implement actual contact addition logic
    state = state.copyWith(isLoading: true);
    
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate processing
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for Favorite Contacts state
final favoriteContactsProvider = StateNotifierProvider<FavoriteContactsNotifier, FavoriteContactsState>((ref) {
  return FavoriteContactsNotifier();
});
