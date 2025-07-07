# Volo Authentication State Management Implementation

## Overview

This document describes the comprehensive authentication state management system implemented in the Volo Flutter app. The system provides intelligent routing based on user authentication state and onboarding status, with full Firestore integration for user data persistence.

## Architecture

### Core Components

1. **AuthWrapper** (`lib/auth_wrapper.dart`)
   - Main authentication state manager
   - Listens to Firebase Auth state changes
   - Routes users to appropriate screens based on their state
   - Provides loading screen during authentication checks

2. **FirebaseService** (`lib/services/firebase_service.dart`)
   - Centralized Firebase operations
   - User profile management (without email collection)
   - Authentication state utilities
   - Firestore data operations

3. **Updated Screens**
   - `OnboardingScreen`: Saves user data to Firestore
   - `ProfileScreen`: Sign out and delete account functionality
   - `HomeScreen`: Real user data integration

## Authentication Flow

### State Management Logic

The app uses a three-state authentication system:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Not Auth      │───▶│  Auth + No       │───▶│  Auth +         │
│                 │    │  Onboarding      │    │  Onboarded      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Welcome        │    │   Onboarding     │    │     Home        │
│  Screen         │    │   Screen         │    │   Screen        │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Routing Logic

1. **Not Authenticated** → Welcome Screen
   - User has not completed phone authentication
   - Shows login flow

2. **Authenticated but Not Onboarded** → Onboarding Screen
   - User has verified phone number but hasn't completed profile setup
   - Collects first name and last name
   - Saves data to Firestore

3. **Authenticated and Onboarded** → Home Screen
   - User has completed both authentication and onboarding
   - Shows main app interface

## Firestore Data Structure

### Users Collection

```javascript
users/{userId} {
  firstName: string,           // Required
  lastName: string,            // Optional
  phoneNumber: string,         // Required (from Firebase Auth)
  isOnboarded: boolean,        // Required (true after onboarding)
  createdAt: timestamp,        // Auto-generated
  updatedAt: timestamp         // Auto-updated
}
```

**Note**: Email is intentionally not collected as per requirements.

### Data Operations

- **Create**: `FirebaseService.saveUserProfile()`
- **Read**: `FirebaseService.getUserProfile()`
- **Update**: `FirebaseService.updateUserProfile()`
- **Delete**: `FirebaseService.deleteUserAccount()`
- **Check Onboarding**: `FirebaseService.isUserOnboarded()`

## Key Features

### 1. Session Persistence
- Firebase Auth automatically persists authentication state
- App remembers user login across app restarts
- No manual token management required

### 2. Intelligent Routing
- AuthWrapper automatically routes users to correct screen
- No manual navigation state management needed
- Handles edge cases (partial onboarding, etc.)

### 3. User Profile Management
- Complete CRUD operations for user data
- Real-time phone number display
- Profile updates with timestamps

### 4. Security Features
- Firebase App Check integration
- Secure user data storage
- Proper authentication state validation

### 5. Error Handling
- Comprehensive error handling throughout
- User-friendly error messages
- Loading states for all async operations

## Implementation Details

### AuthWrapper State Management

```dart
class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isOnboarded = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Listen to Firebase Auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Check onboarding status
        final isOnboarded = await FirebaseService.isUserOnboarded();
        setState(() {
          _currentUser = user;
          _isOnboarded = isOnboarded;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentUser = null;
          _isOnboarded = false;
          _isLoading = false;
        });
      }
    });
  }
}
```

### Onboarding Completion

```dart
Future<void> _completeOnboarding() async {
  // Save user profile to Firestore
  await FirebaseService.saveUserProfile(
    firstName: _firstNameController.text.trim(),
    lastName: _lastNameController.text.trim(),
    phoneNumber: widget.phoneNumber,
  );

  // Navigate to home screen
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => HomeScreen(username: firstName)),
    (route) => false,
  );
}
```

### Sign Out Process

```dart
Future<void> _signOut() async {
  // Sign out from Firebase
  await FirebaseService.signOut();
  
  // Navigate to welcome screen (AuthWrapper handles routing)
  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
}
```

## Usage Examples

### Getting Current User Data

```dart
// Get user profile
final profile = await FirebaseService.getUserProfile();
if (profile != null) {
  final firstName = profile['firstName'];
  final phoneNumber = profile['phoneNumber'];
}

// Check if user is onboarded
final isOnboarded = await FirebaseService.isUserOnboarded();
```

### Updating User Profile

```dart
await FirebaseService.updateUserProfile({
  'firstName': 'New Name',
  'lastName': 'New Last Name',
});
```

### Listening to Auth Changes

```dart
FirebaseService.authStateChanges.listen((User? user) {
  if (user != null) {
    // User is signed in
  } else {
    // User is signed out
  }
});
```

## Testing Scenarios

### 1. Fresh Install
- App starts at Welcome Screen
- User completes phone authentication
- User completes onboarding
- User lands on Home Screen

### 2. Returning User (Onboarded)
- App checks authentication state
- User is authenticated and onboarded
- App directly routes to Home Screen

### 3. Returning User (Not Onboarded)
- App checks authentication state
- User is authenticated but not onboarded
- App routes to Onboarding Screen

### 4. Sign Out
- User signs out from Profile Screen
- AuthWrapper detects state change
- App routes to Welcome Screen

### 5. Account Deletion
- User deletes account from Profile Screen
- User data is removed from Firestore
- User account is deleted from Firebase Auth
- App routes to Welcome Screen

## Security Considerations

1. **Firebase App Check**: Prevents abuse and unauthorized access
2. **Phone Authentication**: Secure phone number verification
3. **Firestore Rules**: Should be configured to protect user data
4. **Data Validation**: Input validation on client side
5. **Error Handling**: Secure error messages without exposing internals

## Future Enhancements

1. **Offline Support**: Cache user data for offline access
2. **Profile Picture**: Add profile picture upload functionality
3. **Data Export**: Allow users to export their data
4. **Account Recovery**: Implement account recovery mechanisms
5. **Multi-Device Sync**: Real-time sync across devices

## Troubleshooting

### Common Issues

1. **User stuck on loading screen**
   - Check Firebase connection
   - Verify App Check configuration
   - Check authentication state

2. **Onboarding not completing**
   - Verify Firestore permissions
   - Check network connectivity
   - Validate input data

3. **Sign out not working**
   - Check Firebase Auth state
   - Verify navigation logic
   - Check for error logs

### Debug Logging

The implementation includes comprehensive logging with the tag 'VoloAuth':

```dart
developer.log('Message', name: 'VoloAuth');
```

Check logs for detailed authentication flow information.

## Conclusion

This authentication state management system provides a robust, secure, and user-friendly experience for the Volo app. It handles all edge cases, provides proper error handling, and integrates seamlessly with Firebase services while maintaining clean separation of concerns. 