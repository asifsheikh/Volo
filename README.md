# Volo - Flight Management App

A modern Flutter application for flight search, booking, and travel management with AI-powered features, built using **Riverpod + Clean Architecture**.

## 🚀 Features

- **Flight Search**: Real-time flight search with comprehensive filtering
- **AI Integration**: Gemini-powered AI assistant for travel queries
- **Contact Management**: Add and manage travel companions
- **Profile Management**: User profile with photo upload
- **Push Notifications**: Real-time flight updates and notifications
- **Network Handling**: Robust offline/online state management
- **Firebase Integration**: Authentication, analytics, and remote config
- **Modern Architecture**: Clean Architecture with Riverpod state management

## 🏗️ Architecture Overview

### **Clean Architecture + Riverpod**

Volo follows **Clean Architecture** principles with **Riverpod** for state management, ensuring:

- **Separation of Concerns**: Clear boundaries between UI, business logic, and data layers
- **Testability**: Easy unit testing with dependency injection
- **Maintainability**: Scalable and maintainable codebase
- **Type Safety**: Compile-time safety with Riverpod's code generation
- **Performance**: Efficient state management with minimal rebuilds

### **Architecture Layers**

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Screens       │  │   Providers     │  │   Widgets    │ │
│  │                 │  │                 │  │              │ │
│  │ • HomeScreen    │  │ • HomeProvider  │  │ • Custom     │ │
│  │ • FlightResults │  │ • FlightProvider│  │   Widgets    │ │
│  │ • ProfileScreen │  │ • ProfileProvider│ │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                            │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │   Entities      │  │   Use Cases     │  │ Repositories │ │
│  │                 │  │                 │  │              │ │
│  │ • HomeState     │  │ • LoadHomeData  │  │ • HomeRepo   │ │
│  │ • FlightState   │  │ • GetFlights    │  │ • FlightRepo │ │
│  │ • ProfileState  │  │ • SaveProfile   │  │ • ProfileRepo│ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                                │
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                             │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ Data Sources    │  │ Repositories    │  │    Models    │ │
│  │                 │  │                 │  │              │ │
│  │ • Remote        │  │ • HomeRepoImpl  │  │ • API Models │ │
│  │ • Local         │  │ • FlightRepoImpl│  │ • DTOs       │ │
│  │ • Cache         │  │ • ProfileRepoImpl│ │              │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## 📱 Screenshots

*[Screenshots will be added here]*

## 🏗️ Project Structure

```
Volo/
├── lib/                           # Main application code
│   ├── core/                      # Core infrastructure
│   │   └── auth_wrapper.dart      # Authentication wrapper
│   ├── features/                  # Feature-based modules (Clean Architecture)
│   │   ├── auth/                  # Authentication feature
│   │   │   ├── domain/            # Domain layer
│   │   │   │   ├── entities/      # Business entities
│   │   │   │   ├── repositories/  # Repository interfaces
│   │   │   │   └── usecases/      # Business logic
│   │   │   ├── data/              # Data layer
│   │   │   │   ├── datasources/   # Data sources
│   │   │   │   ├── models/        # Data models
│   │   │   │   └── repositories/  # Repository implementations
│   │   │   └── presentation/      # Presentation layer
│   │   │       ├── providers/     # Riverpod providers
│   │   │       ├── screens/       # UI screens
│   │   │       └── widgets/       # UI widgets
│   │   ├── home/                  # Home feature
│   │   ├── flight_results/        # Flight results feature
│   │   ├── flight_select/         # Flight selection feature
│   │   ├── add_contacts/          # Contact management feature
│   │   ├── flight_confirmation/   # Flight confirmation feature
│   │   ├── profile/               # Profile management feature
│   │   └── onboarding/            # Onboarding feature
│   ├── screens/                   # Legacy screens (to be migrated)
│   │   ├── auth/                  # Authentication screens
│   │   │   ├── login_screen.dart
│   │   │   └── otp_screen.dart
│   │   └── main_navigation_screen.dart
│   ├── services/                  # Business logic services
│   │   ├── firebase_service.dart  # Firebase integration
│   │   ├── flight_api_service.dart # Flight search API
│   │   ├── network_service.dart   # Network connectivity
│   │   ├── remote_config_service.dart # Feature flags
│   │   ├── profile_picture_service.dart # Image handling
│   │   ├── push_notification_service.dart # Push notifications
│   │   └── trip_service.dart      # Trip management
│   ├── theme/                     # App theming
│   │   └── app_theme.dart
│   ├── config/                    # Configuration
│   │   └── remote_config_defaults.dart
│   ├── firebase_options.dart      # Firebase configuration
│   └── main.dart                  # App entry point
├── assets/                        # Static assets
│   ├── airports_global.json       # Airport data
│   ├── animations/                # Lottie animations
│   ├── app_icon.png              # App icon
│   └── onboarding_illustration3.png
├── android/                       # Android-specific code
├── ios/                          # iOS-specific code
├── test/                         # Test files
├── pubspec.yaml                  # Dependencies
└── README.md                     # This file
```

## 🛠️ Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Dart**: Programming language
- **Material Design**: UI/UX framework
- **Riverpod**: State management and dependency injection
- **Freezed**: Immutable data classes and code generation

### Backend & Services
- **Firebase**: Authentication, analytics, push notifications
- **Google Cloud Run**: Production API backend
- **Gemini AI**: AI-powered assistant features

### Development Tools
- **VS Code/Cursor**: IDE
- **Git**: Version control
- **Flutter CLI**: Development tools
- **build_runner**: Code generation

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- Android Studio / Xcode
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/asifsheikh/Volo.git
   cd Volo
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code** (for Riverpod and Freezed)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Configure Firebase** (if needed)
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)

5. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Development Guide

### Architecture Principles

1. **Clean Architecture**: Clear separation between UI, business logic, and data layers
2. **Feature-Based Organization**: Code organized by business features
3. **Dependency Injection**: Riverpod for dependency injection and state management
4. **Immutable State**: Freezed for immutable data classes
5. **Single Responsibility**: Each class has a single, well-defined responsibility
6. **Dependency Inversion**: High-level modules don't depend on low-level modules

### Adding New Features

1. **Create Feature Structure**:
   ```
   lib/features/your_feature/
   ├── domain/
   │   ├── entities/
   │   ├── repositories/
   │   └── usecases/
   ├── data/
   │   ├── datasources/
   │   ├── models/
   │   └── repositories/
   └── presentation/
       ├── providers/
       ├── screens/
       └── widgets/
   ```

2. **Define Domain Entities** (using Freezed):
   ```dart
   @freezed
   class YourFeatureState with _$YourFeatureState {
     const factory YourFeatureState({
       required String data,
       @Default(false) bool isLoading,
       String? errorMessage,
     }) = _YourFeatureState;
   }
   ```

3. **Create Repository Interface**:
   ```dart
   abstract class YourFeatureRepository {
     Future<YourFeatureState> getData();
   }
   ```

4. **Implement Use Case**:
   ```dart
   @riverpod
   class GetYourFeatureData extends _$GetYourFeatureData {
     @override
     Future<YourFeatureState> build() async {
       // Business logic here
     }
   }
   ```

5. **Create Provider**:
   ```dart
   @riverpod
   Future<YourFeatureState> yourFeatureProvider(YourFeatureProviderRef ref) async {
     return await ref.watch(getYourFeatureDataProvider.future);
   }
   ```

6. **Build UI Screen**:
   ```dart
   class YourFeatureScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final state = ref.watch(yourFeatureProviderProvider);
       return state.when(
         data: (data) => YourUI(data),
         loading: () => LoadingWidget(),
         error: (error, stack) => ErrorWidget(error),
       );
     }
   }
   ```

### Code Style

- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add documentation for public APIs
- Keep functions small and focused
- Use Riverpod for state management
- Use Freezed for immutable data classes

## 🔧 Configuration

### Environment Variables

The app uses Firebase Remote Config for feature flags and configuration:

- `use_mock_flight_data`: Toggle between mock and real API data
- `enable_push_notifications`: Enable/disable push notifications
- `enable_ai_features`: Enable/disable AI assistant features

### API Configuration

- **Production API**: `https://searchflights-3ltmkayg6q-uc.a.run.app`
- **Timeout**: 30 seconds
- **Authentication**: Bearer token (to be implemented)

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage

# Generate code before testing
dart run build_runner build --delete-conflicting-outputs
```

### Test Structure

- **Unit Tests**: Test business logic and use cases
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows
- **Provider Tests**: Test Riverpod providers

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Code Generation
  freezed_annotation: ^2.4.4
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_messaging: ^14.7.10
  firebase_remote_config: ^4.3.8
  
  # Networking & Data
  http: ^1.1.0
  connectivity_plus: ^6.1.4
  shared_preferences: ^2.2.2
  
  # UI & UX
  intl_phone_field: ^3.2.0
  google_generative_ai: ^0.3.0
  confetti: ^0.7.0
  flutter_local_notifications: ^17.2.2
  
  # Contacts
  flutter_contacts: ^1.1.7+1
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  
  # Code Generation
  build_runner: ^2.4.13
  riverpod_generator: ^2.3.9
  freezed: ^2.4.7
```

## 🚀 Deployment

### Android

1. **Build APK**
   ```bash
   flutter build apk --release
   ```

2. **Build App Bundle**
   ```bash
   flutter build appbundle --release
   ```

### iOS

1. **Build for iOS**
   ```bash
   flutter build ios --release
   ```

2. **Archive in Xcode**
   - Open `ios/Runner.xcworkspace`
   - Archive and upload to App Store Connect

## 🔄 CI/CD

The project uses GitHub Actions for continuous integration:

- **Build**: Automated builds on pull requests
- **Test**: Automated testing
- **Code Generation**: Automated code generation
- **Deploy**: Automated deployment to staging

## 📊 Analytics & Monitoring

- **Firebase Analytics**: User behavior tracking
- **Crashlytics**: Crash reporting
- **Performance Monitoring**: App performance metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Generate code: `dart run build_runner build --delete-conflicting-outputs`
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Contribution Guidelines

- Follow Clean Architecture principles
- Use Riverpod for state management
- Use Freezed for data classes
- Add tests for new features
- Update documentation
- Ensure all tests pass
- Generate code before committing

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the [lib/README.md](lib/README.md) for detailed code structure
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions

## 🗺️ Roadmap

### Short Term (Next 3 months)
- [x] **Complete Clean Architecture Migration** ✅
- [x] **Riverpod State Management** ✅
- [x] **Immutable State with Freezed** ✅
- [ ] Enhanced flight search filters
- [ ] Booking integration
- [ ] Offline mode improvements
- [ ] Performance optimizations

### Medium Term (3-6 months)
- [ ] Multi-language support
- [ ] Advanced AI features
- [ ] Social features
- [ ] Payment integration
- [ ] Advanced testing strategies

### Long Term (6+ months)
- [ ] Web platform
- [ ] Desktop app
- [ ] Advanced analytics
- [ ] Machine learning features
- [ ] Microservices architecture

## 🎯 Migration Status

### **✅ Completed Features (100%)**
- **Authentication**: Login, OTP verification
- **Onboarding**: User profile setup, welcome back
- **Home**: Main app interface and navigation
- **Add Flight**: Flight booking initiation
- **Flight Results**: Flight search results
- **Flight Select**: Flight selection and booking
- **Add Contacts**: Contact management for notifications
- **Flight Confirmation**: Booking confirmation with confetti
- **Profile**: User profile and account management

### **✅ Architecture Benefits Achieved**
- **Separation of Concerns**: Clear boundaries between layers
- **Testability**: Easy unit testing with dependency injection
- **Maintainability**: Scalable and maintainable codebase
- **Type Safety**: Compile-time safety with code generation
- **Performance**: Efficient state management with minimal rebuilds
- **Developer Experience**: Better IDE support and debugging

---

**Built with ❤️ using Flutter, Riverpod, and Clean Architecture**
