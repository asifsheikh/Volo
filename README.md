# Volo - Flight Management App

A modern Flutter application for flight search, booking, and travel management with AI-powered features.

## 🚀 Features

- **Flight Search**: Real-time flight search with comprehensive filtering
- **AI Integration**: Gemini-powered AI assistant for travel queries
- **Contact Management**: Add and manage travel companions
- **Profile Management**: User profile with photo upload
- **Push Notifications**: Real-time flight updates and notifications
- **Network Handling**: Robust offline/online state management
- **Firebase Integration**: Authentication, analytics, and remote config

## 📱 Screenshots

*[Screenshots will be added here]*

## 🏗️ Project Structure

```
Volo/
├── lib/                           # Main application code
│   ├── core/                      # Core infrastructure
│   │   ├── base/                  # Base classes
│   │   │   └── base_screen.dart   # Base screen with common functionality
│   │   ├── constants/             # App-wide constants
│   │   │   └── app_constants.dart # Configuration and constants
│   │   ├── models/                # Base model classes
│   │   │   └── base_model.dart    # Base model with JSON serialization
│   │   ├── services/              # Base service classes
│   │   │   └── base_service.dart  # Base API service
│   │   └── utils/                 # Common utilities
│   │       └── validators.dart    # Form validation utilities
│   ├── models/                    # Data models
│   │   └── flight/                # Flight-related models
│   │       └── flight_model.dart  # Flight, FlightOption, AirportInfo
│   ├── services/                  # Business logic services
│   │   ├── api/                   # API services
│   │   │   └── flight_api_service.dart # Flight search API
│   │   ├── firebase_service.dart  # Firebase integration
│   │   ├── network_service.dart   # Network connectivity
│   │   ├── remote_config_service.dart # Feature flags
│   │   ├── profile_picture_service.dart # Image handling
│   │   └── push_notification_service.dart # Push notifications
│   ├── features/                  # Feature-based modules
│   │   ├── add_contacts/          # Contact management
│   │   │   ├── models/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   ├── add_flight/            # Flight addition
│   │   │   ├── controller/
│   │   │   └── screens/
│   │   ├── ai_demo/               # AI assistant
│   │   │   └── screens/
│   │   └── flight_confirmation/   # Flight confirmation
│   │       ├── models/
│   │       ├── screens/
│   │       └── widgets/
│   ├── screens/                   # UI screens
│   │   ├── auth/                  # Authentication
│   │   │   ├── login_screen.dart
│   │   │   └── otp_screen.dart
│   │   ├── home/                  # Home screens
│   │   │   ├── home_screen.dart
│   │   │   ├── flight_results_screen.dart
│   │   │   ├── flight_select_screen.dart
│   │   │   ├── city_connection_header.dart
│   │   │   └── city_dotted_flight_banner.dart
│   │   ├── onboarding/            # Onboarding flow
│   │   │   ├── onboarding_screen.dart
│   │   │   └── welcome_back_screen.dart
│   │   └── profile/               # Profile management
│   │       ├── profile_screen.dart
│   │       └── push_notification_test_screen.dart
│   ├── widgets/                   # Reusable widgets
│   │   ├── network_error_widget.dart
│   │   ├── network_status_indicator.dart
│   │   └── contact_picker_dialog.dart
│   ├── theme/                     # App theming
│   │   └── app_theme.dart
│   ├── config/                    # Configuration
│   │   └── remote_config_defaults.dart
│   ├── core/                      # Core functionality
│   │   └── auth_wrapper.dart
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

### Backend & Services
- **Firebase**: Authentication, analytics, push notifications
- **Google Cloud Run**: Production API backend
- **Gemini AI**: AI-powered assistant features

### Development Tools
- **VS Code/Cursor**: IDE
- **Git**: Version control
- **Flutter CLI**: Development tools

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

3. **Configure Firebase** (if needed)
   - Add your `google-services.json` (Android)
   - Add your `GoogleService-Info.plist` (iOS)

4. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Development Guide

### Code Structure Principles

1. **Feature-Based Organization**: Code is organized by features rather than technical layers
2. **Base Classes**: Common functionality is abstracted into base classes
3. **Dependency Injection**: Services are injected where needed
4. **Separation of Concerns**: UI, business logic, and data layers are separated

### Adding New Features

1. **Create Feature Directory**: Add under `lib/features/`
2. **Follow Structure**: Use models/, screens/, widgets/ subdirectories
3. **Extend Base Classes**: Use `BaseScreen`, `BaseModel`, `BaseService`
4. **Add Tests**: Include unit and widget tests

### Code Style

- Follow Dart/Flutter conventions
- Use meaningful variable and function names
- Add documentation for public APIs
- Keep functions small and focused

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
```

### Test Structure

- **Unit Tests**: Test business logic and services
- **Widget Tests**: Test UI components
- **Integration Tests**: Test complete user flows

## 📦 Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  firebase_messaging: ^14.7.10
  firebase_remote_config: ^4.3.8
  http: ^1.1.0
  connectivity_plus: ^6.1.4
  intl_phone_field: ^3.2.0
  google_generative_ai: ^0.3.0
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
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
- **Deploy**: Automated deployment to staging

## 📊 Analytics & Monitoring

- **Firebase Analytics**: User behavior tracking
- **Crashlytics**: Crash reporting
- **Performance Monitoring**: App performance metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow the existing code style
- Add tests for new features
- Update documentation
- Ensure all tests pass

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the [lib/README.md](lib/README.md) for detailed code structure
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions

## 🗺️ Roadmap

### Short Term (Next 3 months)
- [ ] Enhanced flight search filters
- [ ] Booking integration
- [ ] Offline mode improvements
- [ ] Performance optimizations

### Medium Term (3-6 months)
- [ ] Multi-language support
- [ ] Advanced AI features
- [ ] Social features
- [ ] Payment integration

### Long Term (6+ months)
- [ ] Web platform
- [ ] Desktop app
- [ ] Advanced analytics
- [ ] Machine learning features

---

**Built with ❤️ using Flutter**
