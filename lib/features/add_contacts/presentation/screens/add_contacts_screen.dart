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
import '../../../../features/weather/presentation/widgets/weather_city_card.dart';

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
  @override
  Widget build(BuildContext context) {
    print('🚨🚨🚨 ADD CONTACTS SCREEN BUILD METHOD CALLED 🚨🚨🚨');
    print('🚨🚨🚨 ADD CONTACTS SCREEN BUILD METHOD CALLED 🚨🚨🚨');
    print('🚨🚨🚨 ADD CONTACTS SCREEN BUILD METHOD CALLED 🚨🚨🚨');
    print('=== ADD CONTACTS SCREEN DEBUG: Build method called ===');
    print('=== ADD CONTACTS SCREEN DEBUG: Args = ${widget.args} ===');
    
    final addContactsState = ref.watch(addContactsProviderProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final bannerHeight = screenHeight * 0.4; // 40% of screen height
    
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
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF059393),
                                  const Color(0xFF059393).withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Content
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Keep your loved ones updated',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 28,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Add contacts to receive real-time flight updates and notifications.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16,
                                    color: Colors.white.withOpacity(0.9),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Main content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // VERY VISIBLE TEST WIDGET
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.yellow, width: 3),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🚨 TEST WIDGET - SHOULD BE VISIBLE 🚨',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'If you see this, the weather section should work',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Args: ${widget.args}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Weather Section
                        _buildWeatherSection(),
                        
                        const SizedBox(height: 24),
                        
                        // Notifications Section
                        _buildNotificationsSection(addContactsState),
                        
                        const SizedBox(height: 32),
                        
                        // Contacts Section
                        _buildContactsSection(addContactsState),
                        
                        const SizedBox(height: 32),
                        
                        // Disclaimer Section
                        _buildDisclaimerSection(addContactsState),
                        
                        // Bottom padding to account for the pinned button
                        const SizedBox(height: 100),
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
              onPressed: ref.read(addContactsProviderProvider.notifier).hasActionTaken ? () => _saveTripAndContinue() : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: ref.read(addContactsProviderProvider.notifier).hasActionTaken ? const Color(0xFF059393) : const Color(0xFF9CA3AF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: ref.read(addContactsProviderProvider.notifier).hasActionTaken ? 10 : 0,
                shadowColor: ref.read(addContactsProviderProvider.notifier).hasActionTaken ? Colors.black.withOpacity(0.1) : Colors.transparent,
              ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check, 
                      color: ref.read(addContactsProviderProvider.notifier).hasActionTaken ? Colors.white : const Color(0xFF6B7280), 
                      size: 20
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: ref.read(addContactsProviderProvider.notifier).hasActionTaken ? Colors.white : const Color(0xFF6B7280),
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
                  Icons.info,
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
                      'Privacy & Permissions',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'How we use your data',
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
              IconButton(
                onPressed: () {
                  ref.read(addContactsProviderProvider.notifier).toggleDisclaimer();
                },
                icon: Icon(
                  state.isDisclaimerExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          
          if (state.isDisclaimerExpanded) ...[
            const SizedBox(height: 16),
            Text(
              'We only access your contacts to send flight updates to the people you choose. Your contact data is never shared with third parties and is only used for the purpose you authorize.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
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

  Widget _buildWeatherSection() {
    print('=== WEATHER SECTION DEBUG: Method is being called ===');
    
    // Get IATA codes for departure and arrival cities
    final iataCodes = [
      widget.args.departureAirportCode,
      widget.args.arrivalAirportCode,
    ];

    print('Weather Debug: IATA codes = $iataCodes');
    print('Weather Debug: departureAirportCode = ${widget.args.departureAirportCode}');
    print('Weather Debug: arrivalAirportCode = ${widget.args.arrivalAirportCode}');

    // First, let's show a simple test widget to see if this section is being rendered
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌤️ WEATHER TEST WIDGET',
            style: TextStyle(
              color: Colors.red[800],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'IATA Codes: $iataCodes',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Departure: ${widget.args.departureAirportCode}',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Arrival: ${widget.args.arrivalAirportCode}',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 