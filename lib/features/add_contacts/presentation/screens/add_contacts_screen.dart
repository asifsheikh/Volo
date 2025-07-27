import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../../features/flight_confirmation/screens/confirmation_screen.dart';
import '../../../../features/flight_confirmation/models/confirmation_args.dart';
import '../../widgets/contact_picker_dialog.dart';
import '../providers/add_contacts_provider.dart';
import '../../domain/entities/add_contacts_state.dart' as domain;
import '../../domain/usecases/save_trip.dart';
import '../../../../services/trip_service.dart';
import '../../../../widgets/loading_dialog.dart';
import '../../../../theme/app_theme.dart';
import '../../../../features/weather/presentation/providers/weather_provider.dart';
import '../../../../features/weather/domain/entities/weather_state.dart' as weather_domain;

/// Add Contacts Screen using Riverpod + Clean Architecture
class AddContactsScreen extends ConsumerStatefulWidget {
  final domain.AddContactsArgs args;
  
  const AddContactsScreen({
    Key? key, 
    required this.args,
  }) : super(key: key);

  @override
  ConsumerState<AddContactsScreen> createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends ConsumerState<AddContactsScreen> {
  bool _weatherLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load weather data automatically after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeatherData();
    });
  }

  void _loadWeatherData() {
    if (!_weatherLoaded) {
      final args = widget.args;
      final iataCodes = [args.departureAirportCode, args.arrivalAirportCode];
      
      print('Add Contacts Debug: Auto-loading weather for IATA codes: $iataCodes');
      
      final globalWeatherNotifier = ref.read(globalWeatherNotifierProvider.notifier);
      globalWeatherNotifier.loadWeatherData(iataCodes);
      
      setState(() {
        _weatherLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final addContactsState = ref.watch(addContactsProviderProvider);
    final args = widget.args;
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.4; // 40% of screen height
    
    // Check if at least one action is taken
    final bool hasActionTaken = addContactsState.enableNotifications || addContactsState.selectedContacts.isNotEmpty;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // Sliver App Bar for the banner with fade effect
                SliverAppBar(
                  expandedHeight: bannerHeight,
                  floating: false,
                  pinned: true, // Keep title bar pinned when scrolling
                  backgroundColor: AppTheme.background, // Background color when collapsed
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leading: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6B7280), size: 16),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  title: const Text(
                    'Add Contacts',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white, // White color
                    ),
                  ),
                  centerTitle: false, // Left align the title
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        // Background Images
                        Row(
                          children: [
                            // Departing City (Left 50%)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(args.departureImage.isNotEmpty 
                                        ? args.departureImage 
                                        : args.departureThumbnail.isNotEmpty
                                            ? args.departureThumbnail
                                            : 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=400&h=400&fit=crop'),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // Fallback to gradient
                                    },
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.black.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Main content (icon, IATA, temperature) - centered
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Flight icon
                                            const Icon(
                                              Icons.flight_takeoff,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 12), // Reduced margin
                                            
                                            // IATA code
                                            Text(
                                              args.departureAirportCode.toUpperCase(),
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w900,
                                                fontSize: 32,
                                                color: Colors.white,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Weather information
                                            _buildWeatherInfo(args.departureAirportCode),
                                          ],
                                        ),
                                      ),
                                      
                                      // City name at bottom
                                      Positioned(
                                        bottom: 20,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Text(
                                            args.departureCity.toUpperCase(),
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.white,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Arriving City (Right 50%)
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(args.arrivalImage.isNotEmpty 
                                        ? args.arrivalImage 
                                        : args.arrivalThumbnail.isNotEmpty
                                            ? args.arrivalThumbnail
                                            : 'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=400&h=400&fit=crop'),
                                    fit: BoxFit.cover,
                                    onError: (exception, stackTrace) {
                                      // Fallback to gradient
                                    },
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerRight,
                                      end: Alignment.centerLeft,
                                      colors: [
                                        Colors.black.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      // Main content (icon, IATA, temperature) - centered
                                      Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            // Flight icon
                                            const Icon(
                                              Icons.flight_land,
                                              color: Colors.white,
                                              size: 48,
                                            ),
                                            const SizedBox(height: 12), // Reduced margin
                                            
                                            // IATA code
                                            Text(
                                              args.arrivalAirportCode.toUpperCase(),
                                              style: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w900,
                                                fontSize: 32,
                                                color: Colors.white,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Weather information
                                            _buildWeatherInfo(args.arrivalAirportCode),
                                          ],
                                        ),
                                      ),
                                      
                                      // City name at bottom
                                      Positioned(
                                        bottom: 20,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Text(
                                            args.arrivalCity.toUpperCase(),
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.white,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Content below banner
                      ],
                    ),
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4), // Reduced from 8 to 4
                        
                        const SizedBox(height: 12), // Reduced from 16 to 12
                        
                        // Your Own Updates Section
                        const Text(
                          'Your Own Updates',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8), // Reduced from 12 to 8
                        
                        // Checkbox for own updates
                        Row(
                          children: [
                            Checkbox(
                              value: addContactsState.enableNotifications,
                              onChanged: (value) {
                                ref.read(addContactsProviderProvider.notifier).toggleNotifications();
                              },
                              activeColor: const Color(0xFF008080),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Send me updates about this flight',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "I'll receive all flight updates and notifications for this journey.",
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Reduced from 20 to 16
                        
                        // Share With Close Ones Section
                        const Text(
                          'Share With Close Ones',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        const Text(
                          'Notify my close ones (via WhatsApp)',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Compact Add Contact Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () => ref.read(addContactsProviderProvider.notifier).pickContact(),
                            icon: const Icon(Icons.add, color: Color(0xFF008080), size: 20),
                            label: const Text(
                              'Add Contact',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF008080),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF008080), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        
                        // Selected Contacts
                        if (addContactsState.selectedContacts.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          
                          ...addContactsState.selectedContacts.asMap().entries.map((entry) {
                            final int index = entry.key;
                            final contact = entry.value;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Row(
                                children: [
                                  // Avatar with emoji
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF008080).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Color(0xFF008080),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  
                                  // Contact info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.name,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        if (contact.phoneNumber != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            contact.phoneNumber!,
                                            style: const TextStyle(
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  
                                  // Remove button
                                  IconButton(
                                    onPressed: () => ref.read(addContactsProviderProvider.notifier).removeContact(index),
                                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Disclaimer Section
                        _buildDisclaimerSection(addContactsState),
                        
                        // Bottom padding to account for the pinned button
                        const SizedBox(height: 40), // Reduced from 60 to 40
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Pinned Continue Button at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.background,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: hasActionTaken ? () => _saveTripAndContinue() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasActionTaken ? const Color(0xFF059393) : const Color(0xFF9CA3AF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: hasActionTaken ? 10 : 0,
                  shadowColor: hasActionTaken ? Colors.black.withOpacity(0.1) : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check, 
                      color: hasActionTaken ? Colors.white : const Color(0xFF6B7280), 
                      size: 20
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: hasActionTaken ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(domain.AddContactsState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF059393).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Color(0xFF059393),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enable Notifications',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Get real-time flight updates',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: state.enableNotifications,
                onChanged: (value) {
                  ref.read(addContactsProviderProvider.notifier).toggleNotifications();
                },
                activeColor: const Color(0xFF059393),
              ),
            ],
          ),
          
          if (state.enableNotifications) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You\'ll receive alerts for:',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildAlertItem('Flight delays and cancellations'),
                  _buildAlertItem('Gate changes'),
                  _buildAlertItem('Boarding notifications'),
                  _buildAlertItem('Arrival updates'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactsSection(domain.AddContactsState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF059393).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.people,
                  color: Color(0xFF059393),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add Contacts',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Notify your family and friends',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickContact(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059393),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          if (state.selectedContacts.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...state.selectedContacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              return _buildContactItem(contact, index);
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem(domain.Contact contact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF059393),
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
                if (contact.phoneNumber != null)
                  Text(
                    contact.phoneNumber!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(addContactsProviderProvider.notifier).removeContact(index);
            },
            icon: const Icon(
              Icons.close,
              color: Color(0xFF6B7280),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerSection(domain.AddContactsState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: const Text(
                  'What alerts will be sent to your contacts?',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => ref.read(addContactsProviderProvider.notifier).toggleDisclaimer(),
                icon: Icon(
                  state.isDisclaimerExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          if (state.isDisclaimerExpanded) ...[
            const SizedBox(height: 12),
            _buildAlertItem('Flight status updates (delays, cancellations)'),
            _buildAlertItem('Boarding pass notifications'),
            _buildAlertItem('Gate change alerts'),
            _buildAlertItem('Baggage claim information'),
            _buildAlertItem('Custom messages from you'),
          ],
        ],
      ),
    );
  }

  Future<void> _pickContact() async {
    try {
      // Request permission to access contacts
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        // Show permission denied message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('We need access to your contacts to add people to notify.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Get all contacts with phone numbers
      final List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Filter contacts that have phone numbers
      final contactsWithPhones = contacts.where((contact) => contact.phones.isNotEmpty).toList();

      if (contactsWithPhones.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No contacts with phone numbers found in your device.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get list of already selected phone numbers
      final currentState = ref.read(addContactsProviderProvider);
      final selectedPhoneNumbers = currentState.selectedContacts
          .where((contact) => contact.phoneNumber != null)
          .map((contact) => contact.phoneNumber!)
          .toList();

      // Show modern contact picker dialog
      final Contact? selectedContact = await showDialog<Contact>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ContactPickerDialog(
            contacts: contactsWithPhones,
            selectedPhoneNumbers: selectedPhoneNumbers,
          );
        },
      );

      if (selectedContact != null) {
        final phoneNumber = selectedContact.phones.first.number;
        final contactName = selectedContact.displayName.isNotEmpty 
            ? selectedContact.displayName 
            : (selectedContact.name.first.isNotEmpty || selectedContact.name.last.isNotEmpty)
                ? '${selectedContact.name.first} ${selectedContact.name.last}'.trim()
                : 'Unknown Contact';
        
        final newContact = domain.Contact(
          name: contactName,
          phoneNumber: phoneNumber,
        );
        
        // Check if contact already exists
        if (ref.read(addContactsProviderProvider.notifier).contactExists(newContact)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('This contact is already added to your list.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        
        // Add contact
        ref.read(addContactsProviderProvider.notifier).addContact(newContact);
      }
    } catch (e) {
      print('Error picking contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to access contacts. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveTripAndContinue() async {
    try {
      final addContactsNotifier = ref.read(addContactsProviderProvider.notifier);
      final currentState = ref.read(addContactsProviderProvider);
      
      // Set saving state
      addContactsNotifier.setSaving(true);
      
      // Show loading dialog
      LoadingDialog.show(
        context: context,
        message: 'Saving your trip...',
      );

      // Save trip using the use case
      final saveTripNotifier = ref.read(saveTripProvider.notifier);
      await saveTripNotifier.saveTrip(
        flightOption: widget.args.selectedFlight,
        contacts: currentState.selectedContacts,
        userNotifications: currentState.enableNotifications,
        departureCity: widget.args.departureCity,
        arrivalCity: widget.args.arrivalCity,
      );

      // Hide loading dialog
      LoadingDialog.hide(context);

      // Navigate to confirmation screen
      _navigateToConfirmationScreen(currentState);

    } catch (e) {
      // Hide loading dialog if it's still showing
      LoadingDialog.hide(context);
      
      // Set error state
      ref.read(addContactsProviderProvider.notifier).setError(e.toString());
      
      // Show error message
      _showErrorSnackBar('Failed to save trip: ${e.toString()}');
    } finally {
      // Clear saving state
      ref.read(addContactsProviderProvider.notifier).setSaving(false);
    }
  }

  void _navigateToConfirmationScreen(domain.AddContactsState state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          args: ConfirmationArgs(
            fromCity: widget.args.departureCity,
            toCity: widget.args.arrivalCity,
            contactNames: state.selectedContacts.map((c) => c.name).toList(),
            contactAvatars: state.selectedContacts.map((c) => c.avatar ?? '').toList(),
            departureAirportCode: widget.args.departureAirportCode,
            departureImage: widget.args.departureImage,
            departureThumbnail: widget.args.departureThumbnail,
            arrivalAirportCode: widget.args.arrivalAirportCode,
            arrivalImage: widget.args.arrivalImage,
            arrivalThumbnail: widget.args.arrivalThumbnail,
            enableNotifications: state.enableNotifications,
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC2626),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildAlertItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(String airportCode) {
    return Consumer(
      builder: (context, ref, child) {
        final globalWeather = ref.watch(globalWeatherNotifierProvider);
        final weather = globalWeather[airportCode];
        
        print('Weather Debug: Building weather for $airportCode, weather data: ${weather != null ? 'available' : 'null'}');
        
        if (weather != null) {
          // Just show temperature with simple formatting
          return Text(
            '${weather.current.temperature.round()}°C',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800, // Slightly bolder
              fontSize: 20, // Larger font size
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          );
        } else {
          // Show nothing when weather data is not available
          print('Weather Debug: No weather data for $airportCode, showing SizedBox.shrink()');
          return const SizedBox.shrink();
        }
      },
    );
  }
} 