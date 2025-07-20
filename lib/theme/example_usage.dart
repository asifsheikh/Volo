import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Example screen demonstrating how to use the centralized AppTheme
/// This shows best practices for using colors, typography, and styles
class ExampleUsageScreen extends StatelessWidget {
  const ExampleUsageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color from theme
      backgroundColor: AppTheme.background,
      
      appBar: AppBar(
        title: const Text('Theme Example'),
        // App bar automatically uses theme colors
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Typography examples
            Text('Headline Large', style: AppTheme.headlineLarge),
            const SizedBox(height: AppTheme.spacing16),
            Text('Headline Medium', style: AppTheme.headlineMedium),
            const SizedBox(height: AppTheme.spacing16),
            Text('Body Large', style: AppTheme.bodyLarge),
            const SizedBox(height: AppTheme.spacing16),
            Text('Body Medium', style: AppTheme.bodyMedium),
            const SizedBox(height: AppTheme.spacing32),
            
            // Color examples
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacing16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Color Examples', style: AppTheme.titleMedium),
                  const SizedBox(height: AppTheme.spacing12),
                  
                  // Color swatches
                  _buildColorSwatch('Primary', AppTheme.primary),
                  _buildColorSwatch('Secondary', AppTheme.secondary),
                  _buildColorSwatch('Success', AppTheme.success),
                  _buildColorSwatch('Warning', AppTheme.warning),
                  _buildColorSwatch('Destructive', AppTheme.destructive),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing32),
            
            // Button examples
            Text('Button Examples', style: AppTheme.titleMedium),
            const SizedBox(height: AppTheme.spacing16),
            
            // Primary button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: AppTheme.primaryButton,
                child: const Text('Primary Button'),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing12),
            
            // Secondary button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: AppTheme.secondaryButton,
                child: const Text('Secondary Button'),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing12),
            
            // Disabled button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: null,
                style: AppTheme.disabledButton,
                child: const Text('Disabled Button'),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing12),
            
            // Destructive button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: AppTheme.destructiveButton,
                child: const Text('Delete'),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacing32),
            
            // Input field example
            Text('Input Field Example', style: AppTheme.titleMedium),
            const SizedBox(height: AppTheme.spacing16),
            
            TextField(
              decoration: AppTheme.inputDecoration.copyWith(
                hintText: 'Enter your text here',
                labelText: 'Example Input',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String name, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppTheme.radius8),
              border: Border.all(color: AppTheme.borderPrimary),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Text(name, style: AppTheme.bodyMedium),
          const SizedBox(width: AppTheme.spacing8),
          Text(color.value.toRadixString(16).toUpperCase(), 
               style: AppTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Example of how to create a custom widget using the theme
class ThemedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool elevated;

  const ThemedCard({
    Key? key,
    required this.child,
    this.padding,
    this.elevated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing16),
      decoration: elevated 
          ? AppTheme.elevatedCardDecoration 
          : AppTheme.cardDecoration,
      child: child,
    );
  }
}

/// Example of how to create a themed button
class ThemedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isSecondary;

  const ThemedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isDestructive = false,
    this.isSecondary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ButtonStyle style;
    
    if (onPressed == null) {
      style = AppTheme.disabledButton;
    } else if (isDestructive) {
      style = AppTheme.destructiveButton;
    } else if (isSecondary) {
      style = AppTheme.secondaryButton;
    } else {
      style = AppTheme.primaryButton;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Text(text),
      ),
    );
  }
} 