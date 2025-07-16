// Data model for a contact
class ContactModel {
  final String name;
  final String? avatar; // URL or asset
  final String? platform; // e.g., 'WhatsApp'
  final String? phoneNumber;
  
  ContactModel({
    required this.name,
    this.avatar,
    this.platform,
    this.phoneNumber,
  });
} 