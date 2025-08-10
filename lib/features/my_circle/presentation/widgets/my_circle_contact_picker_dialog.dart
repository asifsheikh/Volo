import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/models/my_circle_contact_model.dart';
import '../../../../theme/app_theme.dart';

class MyCircleContactPickerDialog extends StatefulWidget {
  final List<MyCircleContactModel> contacts;
  final List<String> selectedPhoneNumbers;

  const MyCircleContactPickerDialog({
    Key? key,
    required this.contacts,
    this.selectedPhoneNumbers = const [],
  }) : super(key: key);

  @override
  State<MyCircleContactPickerDialog> createState() => _MyCircleContactPickerDialogState();
}

class _MyCircleContactPickerDialogState extends State<MyCircleContactPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<MyCircleContactModel> _filteredContacts = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredContacts = widget.contacts;
      } else {
        _filteredContacts = widget.contacts.where((contact) {
          final name = contact.name.toLowerCase();
          final phone = contact.whatsappNumber.toLowerCase();
          return name.contains(query) || phone.contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  String _getInitials(String name) {
    final nameParts = name.trim().split(' ');
    if (nameParts.isEmpty) return '?';
    if (nameParts.length == 1) {
      return nameParts[0].isNotEmpty ? nameParts[0][0].toUpperCase() : '?';
    }
    return '${nameParts[0][0].toUpperCase()}${nameParts.last[0].toUpperCase()}';
  }

  /// Get intelligent icon based on contact name
  Widget _getContactIcon(String name) {
    final lowerName = name.toLowerCase().trim();
    
    // Family relationships
    if (lowerName.contains('mom') || lowerName.contains('mother') || lowerName.contains('mama')) {
      return FaIcon(
        FontAwesomeIcons.personDress,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('dad') || lowerName.contains('father') || lowerName.contains('papa')) {
      return FaIcon(
        FontAwesomeIcons.person,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('brother') || lowerName.contains('bro')) {
      return FaIcon(
        FontAwesomeIcons.person,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('sister') || lowerName.contains('sis')) {
      return FaIcon(
        FontAwesomeIcons.personDress,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('grandma') || lowerName.contains('grandmother') || lowerName.contains('nana')) {
      return FaIcon(
        FontAwesomeIcons.personDress,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('grandpa') || lowerName.contains('grandfather')) {
      return FaIcon(
        FontAwesomeIcons.person,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('uncle')) {
      return FaIcon(
        FontAwesomeIcons.person,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('aunt')) {
      return FaIcon(
        FontAwesomeIcons.personDress,
        color: Colors.white,
        size: 20,
      );
    }
    
    // Partner relationships
    if (lowerName.contains('wife') || lowerName.contains('spouse') || lowerName.contains('partner')) {
      return FaIcon(
        FontAwesomeIcons.heart,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('husband') || lowerName.contains('boyfriend')) {
      return FaIcon(
        FontAwesomeIcons.heart,
        color: Colors.white,
        size: 20,
      );
    }
    
    // Professional relationships
    if (lowerName.contains('boss') || lowerName.contains('manager') || lowerName.contains('colleague')) {
      return FaIcon(
        FontAwesomeIcons.briefcase,
        color: Colors.white,
        size: 20,
      );
    }
    
    if (lowerName.contains('doctor') || lowerName.contains('dr.')) {
      return FaIcon(
        FontAwesomeIcons.userDoctor,
        color: Colors.white,
        size: 20,
      );
    }
    
    // Friend relationships
    if (lowerName.contains('friend') || lowerName.contains('buddy') || lowerName.contains('pal')) {
      return FaIcon(
        FontAwesomeIcons.userGroup,
        color: Colors.white,
        size: 20,
      );
    }
    
    // Default to first letter
    return Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: AppTheme.titleMedium.copyWith(
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 600,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  FaIcon(
                    FontAwesomeIcons.users,
                    color: AppTheme.textOnPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select from My Circle',
                      style: AppTheme.titleLarge.copyWith(
                        color: AppTheme.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.textOnPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          onPressed: _clearSearch,
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderPrimary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppTheme.cardBackground,
                ),
              ),
            ),
            
            // Contacts List
            Flexible(
              child: _filteredContacts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.users,
                              color: AppTheme.textSecondary,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching ? 'No contacts found' : 'No contacts in My Circle',
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isSearching 
                                  ? 'Try a different search term'
                                  : 'Add contacts to your circle first',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        final isSelected = widget.selectedPhoneNumbers.contains(contact.whatsappNumber);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? AppTheme.primary.withOpacity(0.1)
                                : AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? AppTheme.primary
                                  : AppTheme.borderPrimary,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _getContactColor(contact.name),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _getContactIcon(contact.name),
                              ),
                            ),
                            title: Text(
                              contact.name,
                              style: AppTheme.titleMedium.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: AppTheme.success,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      contact.whatsappNumber,
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: AppTheme.textSecondary,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      contact.language,
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: isSelected
                                ? FaIcon(
                                    FontAwesomeIcons.checkCircle,
                                    color: AppTheme.primary,
                                    size: 20,
                                  )
                                : null,
                            onTap: () {
                              Navigator.of(context).pop(contact);
                            },
                          ),
                        );
                      },
                    ),
            ),
            
            // Bottom Padding
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
