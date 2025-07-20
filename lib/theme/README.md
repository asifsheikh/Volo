# Volo App Theme System

This directory contains the centralized theme configuration for the Volo app. All colors, typography, spacing, and design tokens are defined in one place for consistency and maintainability.

## 📁 Files

- `app_theme.dart` - Main theme configuration with all design tokens
- `example_usage.dart` - Examples of how to use the theme
- `README.md` - This documentation

## 🎨 Usage

### Basic Usage

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          Text('Hello World', style: AppTheme.headlineLarge),
          ElevatedButton(
            onPressed: () {},
            style: AppTheme.primaryButton,
            child: Text('Click Me'),
          ),
        ],
      ),
    );
  }
}
```

### Colors

```dart
// Primary brand color (Teal)
AppTheme.primary

// Secondary color (Gray)
AppTheme.secondary

// Destructive color (Red)
AppTheme.destructive

// Success color (Green)
AppTheme.success

// Warning color (Orange)
AppTheme.warning

// Background colors
AppTheme.background      // Main app background
AppTheme.cardBackground  // Card backgrounds
AppTheme.surfaceBackground // Elevated surfaces

// Text colors
AppTheme.textPrimary     // Main text
AppTheme.textSecondary   // Secondary text
AppTheme.textTertiary    // Tertiary text
AppTheme.textOnPrimary   // Text on colored backgrounds
AppTheme.textDisabled    // Disabled text
```

### Typography

```dart
// Headlines
AppTheme.headlineLarge   // 28px, Bold
AppTheme.headlineMedium  // 24px, Bold
AppTheme.headlineSmall   // 20px, Semi-bold

// Titles
AppTheme.titleLarge      // 18px, Semi-bold
AppTheme.titleMedium     // 16px, Semi-bold
AppTheme.titleSmall      // 14px, Medium

// Body text
AppTheme.bodyLarge       // 16px, Regular
AppTheme.bodyMedium      // 14px, Regular
AppTheme.bodySmall       // 12px, Regular

// Labels
AppTheme.labelLarge      // 14px, Medium
AppTheme.labelMedium     // 12px, Medium
AppTheme.labelSmall      // 11px, Medium
```

### Button Styles

```dart
// Primary button (Teal)
ElevatedButton(
  style: AppTheme.primaryButton,
  child: Text('Primary Action'),
)

// Secondary button (White with border)
ElevatedButton(
  style: AppTheme.secondaryButton,
  child: Text('Secondary Action'),
)

// Disabled button (Gray)
ElevatedButton(
  style: AppTheme.disabledButton,
  onPressed: null,
  child: Text('Disabled'),
)

// Destructive button (Red)
ElevatedButton(
  style: AppTheme.destructiveButton,
  child: Text('Delete'),
)
```

### Spacing

```dart
// Use consistent spacing values
SizedBox(height: AppTheme.spacing8)   // 8px
SizedBox(height: AppTheme.spacing16)  // 16px
SizedBox(height: AppTheme.spacing24)  // 24px
SizedBox(height: AppTheme.spacing32)  // 32px
SizedBox(height: AppTheme.spacing48)  // 48px
```

### Border Radius

```dart
// Use consistent border radius values
BorderRadius.circular(AppTheme.radius8)   // 8px
BorderRadius.circular(AppTheme.radius12)  // 12px
BorderRadius.circular(AppTheme.radius16)  // 16px
BorderRadius.circular(AppTheme.radius20)  // 20px
BorderRadius.circular(AppTheme.radius24)  // 24px
```

### Input Fields

```dart
TextField(
  decoration: AppTheme.inputDecoration.copyWith(
    hintText: 'Enter your text',
    labelText: 'Label',
  ),
)
```

### Cards

```dart
// Basic card
Container(
  decoration: AppTheme.cardDecoration,
  child: Text('Card content'),
)

// Elevated card
Container(
  decoration: AppTheme.elevatedCardDecoration,
  child: Text('Elevated card content'),
)
```

## 🚀 Best Practices

### 1. Always Use Theme Colors
❌ Don't hardcode colors:
```dart
color: Color(0xFF059393)  // Bad
```

✅ Use theme colors:
```dart
color: AppTheme.primary   // Good
```

### 2. Use Consistent Typography
❌ Don't create custom text styles:
```dart
Text('Hello', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
```

✅ Use predefined styles:
```dart
Text('Hello', style: AppTheme.titleMedium)
```

### 3. Use Consistent Spacing
❌ Don't use random spacing values:
```dart
SizedBox(height: 15)  // Bad
```

✅ Use theme spacing:
```dart
SizedBox(height: AppTheme.spacing16)  // Good
```

### 4. Create Reusable Components
Instead of repeating button styles, create themed components:

```dart
class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;

  const ThemedButton({
    required this.text,
    this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: isDestructive ? AppTheme.destructiveButton : AppTheme.primaryButton,
      child: Text(text),
    );
  }
}
```

## 🔧 Adding New Design Tokens

When adding new colors, typography, or other design tokens:

1. Add them to the appropriate section in `app_theme.dart`
2. Use descriptive names that follow the existing pattern
3. Add documentation comments
4. Update this README if needed
5. Consider adding examples to `example_usage.dart`

## 📱 Theme Integration

The theme is automatically applied to the entire app through `main.dart`:

```dart
MaterialApp(
  theme: AppTheme.theme,
  // ... other app configuration
)
```

This ensures that all Material widgets (AppBar, BottomNavigationBar, etc.) automatically use the theme colors and styles.

## 🎯 Benefits

- **Consistency**: All screens use the same design tokens
- **Maintainability**: Change colors/styles in one place
- **Scalability**: Easy to add new design tokens
- **Developer Experience**: Clear guidelines and examples
- **Brand Consistency**: Ensures the app follows brand guidelines 