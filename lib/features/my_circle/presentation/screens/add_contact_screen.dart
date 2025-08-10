import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/ai_service.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import '../../../../widgets/contact_picker_dialog.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  final String username;
  const AddContactScreen({Key? key, required this.username}) : super(key: key);

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contactNameController = TextEditingController();
  final _whatsappNumberController = TextEditingController();
  
  String? _selectedTimezone;
  String? _selectedLanguage;
  String? _sampleMessage;
  bool _isLoading = false;

  final List<String> _timezones = [
    'UTC', 'America/New_York', 'America/Los_Angeles', 'Europe/London', 'Europe/Paris',
    'Asia/Tokyo', 'Asia/Dubai', 'Asia/Kolkata', 'Australia/Sydney', 'Pacific/Auckland',
  ];

  final List<String> _languages = [
    'English', 'Hindi', 'Spanish', 'French', 'German', 'Italian', 'Portuguese', 'Russian',
    'Chinese (Simplified)', 'Japanese', 'Korean', 'Arabic', 'Turkish', 'Dutch', 'Swedish',
    'Norwegian', 'Danish', 'Finnish', 'Polish', 'Czech', 'Hungarian', 'Romanian', 'Bulgarian',
    'Greek', 'Hebrew', 'Thai', 'Vietnamese', 'Indonesian', 'Malay', 'Filipino', 'Hinglish',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = 'English';
    _selectedTimezone = 'UTC';
    _generateSampleMessage();
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _whatsappNumberController.dispose();
    super.dispose();
  }

  Future<void> _generateSampleMessage() async {
    if (_selectedLanguage == null) return;
    setState(() { _isLoading = true; });
    
    try {
      // Use Firebase AI to generate sample message
      final template = "${widget.username}'s flight is starting its descent and is expected to touch down at London Heathrow in about 20 minutes. Current weather in London is 5°C with light rain — a perfect London welcome! ☔";
      
      // Use dedicated AI service for message generation
      String message = await AIService().generateFlightMessage(
        username: widget.username,
        language: _selectedLanguage!,
        customTemplate: template,
      );
      
      setState(() { 
        _sampleMessage = message; 
        _isLoading = false; 
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating sample message: $e'), 
          backgroundColor: AppTheme.destructive
        )
      );
    }
  }

  Future<String> _generateAIMessage(String template, String language) async {
    // Use dedicated AI service for message generation
    return await AIService().generateFlightMessage(
      username: widget.username,
      language: language,
      customTemplate: template,
    );
  }

  Future<void> _openContactPicker() async {
    try {
      // Request permission to access contacts
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('We need access to your contacts to add people to your circle.'),
            backgroundColor: AppTheme.destructive,
          ),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No contacts with phone numbers found in your device.'),
            backgroundColor: AppTheme.warning,
          ),
        );
        return;
      }

      // Show contact picker dialog
      final Contact? selectedContact = await showDialog<Contact>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ContactPickerDialog(
            contacts: contactsWithPhones,
            selectedPhoneNumbers: const [], // No pre-selected contacts for this screen
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
        
        // Update the form fields
        setState(() {
          _contactNameController.text = contactName;
          _whatsappNumberController.text = phoneNumber;
        });
        
        // Generate sample message with the new contact name
        _generateSampleMessage();
      }
    } catch (e) {
      print('Error picking contact: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to access contacts. Please try again.'),
          backgroundColor: AppTheme.destructive,
        ),
      );
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contact added successfully!'),
          backgroundColor: AppTheme.primary,
        ),
      );
      Navigator.of(context).pop();
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
        title: Text('Add Contact', style: AppTheme.headlineMedium),
        centerTitle: false, // Left align the title
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Contact Name
              _buildTextField(
                controller: _contactNameController,
                label: 'Contact Name',
                hint: 'What do you call them? (e.g., Mom, Dad, Jo)',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.trim().isEmpty ? 'Contact name is required' : null,
              ),
              const SizedBox(height: 16),
              
              // WhatsApp Number
              _buildTextField(
                controller: _whatsappNumberController,
                label: 'WhatsApp Number',
                hint: 'Enter or pick from contacts',
                icon: Icons.phone_outlined,
                validator: (value) => value == null || value.trim().isEmpty ? 'WhatsApp number is required' : null,
                suffixIcon: IconButton(
                  icon: Icon(Icons.contact_phone, color: AppTheme.primary),
                  onPressed: _openContactPicker,
                ),
              ),
              const SizedBox(height: 16),
              
              // Timezone
              _buildDropdown(
                label: 'Contact\'s Timezone',
                value: _selectedTimezone,
                items: _timezones,
                icon: Icons.public_outlined,
                onChanged: (value) {
                  setState(() { _selectedTimezone = value; });
                },
                validator: (value) => value == null || value.isEmpty ? 'Timezone is required' : null,
              ),
              const SizedBox(height: 16),
              
              // Communication Language
              _buildDropdown(
                label: 'Communication Language',
                value: _selectedLanguage,
                items: _languages,
                icon: Icons.language_outlined,
                onChanged: (value) {
                  setState(() { 
                    _selectedLanguage = value;
                    _generateSampleMessage(); // Regenerate message when language changes
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Language is required' : null,
              ),
              const SizedBox(height: 32),
              
              // Sample Message Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowPrimary,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        FaIcon(FontAwesomeIcons.whatsapp, color: AppTheme.success, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'WhatsApp Message Preview',
                          style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // WhatsApp-style message bubble
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(4),
                        ),
                        border: Border.all(
                          color: AppTheme.success.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                                                              FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: AppTheme.success,
                                  size: 16,
                                ),
                              const SizedBox(width: 8),
                              Text(
                                'Volo Assistant',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Now',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _isLoading
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.success),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Generating message...',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  _sampleMessage ?? 'Select a language to see sample message',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This is a sample message that will be sent via WhatsApp by the Volo app for every flight event (takeoff, landing, delays, etc.). The actual message will be personalized based on real-time flight data and weather conditions.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Enhanced Submit Button
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
                  onPressed: _handleSubmit,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.cardBackground,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.destructive),
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.titleMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardBackground,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.destructive),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
