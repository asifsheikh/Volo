import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/my_circle_service.dart';
import '../../data/models/my_circle_contact_model.dart';
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
  List<MyCircleContactModel> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  /// Load contacts from Firestore
  Future<void> _loadContacts() async {
    try {
      print('FavoriteContactsScreen: Loading contacts...');
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final contacts = await MyCircleService.getMyCircleContacts();
      print('FavoriteContactsScreen: Loaded ${contacts.length} contacts');
      
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
      print('FavoriteContactsScreen: State updated with ${_contacts.length} contacts');
    } catch (e) {
      print('FavoriteContactsScreen: Error loading contacts: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  /// Handle Add Contact button tap
  void _handleAddContact() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddContactScreen(username: widget.username),
      ),
    );
    
    // Reload contacts if a new one was added
    if (result == true) {
      _loadContacts();
    }
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your circle...',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.exclamationTriangle,
              color: AppTheme.destructive,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading contacts',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadContacts,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_contacts.isEmpty) {
      return _buildEmptyState();
    }

    return _buildContactsList();
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
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
                      child: FaIcon(
                        FontAwesomeIcons.users,
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
                    FaIcon(FontAwesomeIcons.userPlus, size: 20, color: AppTheme.textOnPrimary),
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
    );
  }

  Widget _buildContactsList() {
    print('FavoriteContactsScreen: Building contacts list with ${_contacts.length} contacts');
    return Column(
      children: [
        // Contacts List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              return _buildContactCard(contact);
            },
          ),
        ),
        
        // Bottom Add Contact Button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border(
              top: BorderSide(
                color: AppTheme.borderPrimary,
                width: 1,
              ),
            ),
          ),
          child: Container(
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
                  FaIcon(FontAwesomeIcons.userPlus, size: 20, color: AppTheme.textOnPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Add More Contacts',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(MyCircleContactModel contact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderPrimary,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowPrimary,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Intelligent Circular Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getContactColor(contact.name),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _getContactIcon(contact.name),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Contact Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.whatsapp,
                            color: AppTheme.success,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            contact.whatsappNumber,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.language,
                            color: AppTheme.textSecondary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            contact.language,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.public,
                            color: AppTheme.textSecondary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            contact.timezone,
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Edit Button (Pencil Icon) - Top Right
          Positioned(
            top: 12,
            right: 12,
                          child: IconButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddContactScreen(
                        username: widget.username,
                        editMode: true,
                        existingContact: contact,
                      ),
                    ),
                  );
                  
                  // Reload contacts if changes were made
                  if (result == true) {
                    _loadContacts();
                  }
                },
              icon: FaIcon(
                FontAwesomeIcons.penToSquare,
                color: AppTheme.textSecondary,
                size: 18,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get intelligent icon based on contact name
  Widget _getContactIcon(String name) {
    final lowerName = name.toLowerCase().trim();
    
    // Family relationships
    if (lowerName.contains('mom') || lowerName.contains('mother') || lowerName.contains('mama')) {
      return FaIcon(
        FontAwesomeIcons.personDress,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('dad') || lowerName.contains('father') || lowerName.contains('papa')) {
      return FaIcon(
        FontAwesomeIcons.person,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('brother') || lowerName.contains('bro')) {
      return FaIcon(
        FontAwesomeIcons.person,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('sister') || lowerName.contains('sis')) {
      return FaIcon(
        FontAwesomeIcons.personDress,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('grandma') || lowerName.contains('grandmother') || lowerName.contains('nana')) {
      return FaIcon(
        FontAwesomeIcons.personDress,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('grandpa') || lowerName.contains('grandfather') || lowerName.contains('papa')) {
      return FaIcon(
        FontAwesomeIcons.person,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('uncle')) {
      return FaIcon(
        FontAwesomeIcons.person,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('aunt')) {
      return FaIcon(
        FontAwesomeIcons.personDress,
        color: Colors.white,
        size: 24,
      );
    }
    
    // Partner relationships
    if (lowerName.contains('wife') || lowerName.contains('spouse') || lowerName.contains('partner')) {
      return FaIcon(
        FontAwesomeIcons.heart,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('husband') || lowerName.contains('boyfriend')) {
      return FaIcon(
        FontAwesomeIcons.heart,
        color: Colors.white,
        size: 24,
      );
    }
    
    // Professional relationships
    if (lowerName.contains('boss') || lowerName.contains('manager') || lowerName.contains('colleague')) {
      return FaIcon(
        FontAwesomeIcons.briefcase,
        color: Colors.white,
        size: 24,
      );
    }
    
    if (lowerName.contains('doctor') || lowerName.contains('dr.')) {
      return FaIcon(
        FontAwesomeIcons.userDoctor,
        color: Colors.white,
        size: 24,
      );
    }
    
    // Friend relationships
    if (lowerName.contains('friend') || lowerName.contains('buddy') || lowerName.contains('pal')) {
      return FaIcon(
        FontAwesomeIcons.userGroup,
        color: Colors.white,
        size: 24,
      );
    }
    
    // Default to first letter
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: AppTheme.titleLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Get intelligent color based on contact name
  Color _getContactColor(String name) {
    final lowerName = name.toLowerCase().trim();
    
    // Family - Warm colors
    if (lowerName.contains('mom') || lowerName.contains('mother') || lowerName.contains('mama')) {
      return const Color(0xFFFF6B9D); // Pink
    }
    
    if (lowerName.contains('dad') || lowerName.contains('father') || lowerName.contains('papa')) {
      return const Color(0xFF4A90E2); // Blue
    }
    
    if (lowerName.contains('brother') || lowerName.contains('bro')) {
      return const Color(0xFF50C878); // Green
    }
    
    if (lowerName.contains('sister') || lowerName.contains('sis')) {
      return const Color(0xFFFFB6C1); // Light pink
    }
    
    if (lowerName.contains('grandma') || lowerName.contains('grandmother') || lowerName.contains('nana')) {
      return const Color(0xFFDDA0DD); // Plum
    }
    
    if (lowerName.contains('grandpa') || lowerName.contains('grandfather')) {
      return const Color(0xFF8B4513); // Brown
    }
    
    if (lowerName.contains('uncle')) {
      return const Color(0xFF4682B4); // Steel blue
    }
    
    if (lowerName.contains('aunt')) {
      return const Color(0xFFFF69B4); // Hot pink
    }
    
    // Partner - Romantic colors
    if (lowerName.contains('wife') || lowerName.contains('spouse') || lowerName.contains('partner')) {
      return const Color(0xFFE91E63); // Pink
    }
    
    if (lowerName.contains('husband') || lowerName.contains('boyfriend')) {
      return const Color(0xFF9C27B0); // Purple
    }
    
    // Professional - Business colors
    if (lowerName.contains('boss') || lowerName.contains('manager') || lowerName.contains('colleague')) {
      return const Color(0xFF607D8B); // Blue grey
    }
    
    if (lowerName.contains('doctor') || lowerName.contains('dr.')) {
      return const Color(0xFF00BCD4); // Cyan
    }
    
    // Friend - Social colors
    if (lowerName.contains('friend') || lowerName.contains('buddy') || lowerName.contains('pal')) {
      return const Color(0xFF4CAF50); // Green
    }
    
    // Default - Generate color from name hash
    return _generateColorFromName(name);
  }

  /// Generate consistent color from name hash
  Color _generateColorFromName(String name) {
    final colors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF2196F3), // Blue
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF009688), // Teal
      const Color(0xFF4CAF50), // Green
      const Color(0xFF8BC34A), // Light green
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFFFF9800), // Orange
      const Color(0xFFFF5722), // Deep orange
      const Color(0xFF795548), // Brown
      const Color(0xFF9E9E9E), // Grey
    ];
    
    int hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}
