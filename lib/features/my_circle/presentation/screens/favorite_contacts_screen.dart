import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/app_theme.dart';
import 'add_contact_screen.dart';

class FavoriteContactsScreen extends ConsumerStatefulWidget {
  final String username;

  const FavoriteContactsScreen({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  ConsumerState<FavoriteContactsScreen> createState() => _FavoriteContactsScreenState();
}

class _FavoriteContactsScreenState extends ConsumerState<FavoriteContactsScreen> {
  /// Handle Add Contact button tap
  void _handleAddContact() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddContactScreen(username: widget.username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Circle',
          style: AppTheme.headlineMedium,
        ),
        centerTitle: false, // Left align the title
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Enhanced Illustration Placeholder
              Container(
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.borderPrimary,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowPrimary,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.group_outlined,
                          size: 32,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'My Circle',
                        style: AppTheme.titleLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your favorite contacts to keep\nthem updated about your travels',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Enhanced Add Contact Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _handleAddContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppTheme.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add, size: 20, color: AppTheme.textOnPrimary),
                      const SizedBox(width: 8),
                                              Text(
                          'Add to My Circle',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textOnPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Enhanced Info Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.success.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                                                       FaIcon(
                                     FontAwesomeIcons.whatsapp,
                                     color: AppTheme.success,
                                     size: 20,
                                   ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your circle will receive personalized WhatsApp messages to keep them informed about your travels.',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
