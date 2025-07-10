import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'dart:math' as math;
import 'city_connection_header.dart';

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

// Arguments for AddContactsScreen
class AddContactsScreenArgs {
  final dynamic selectedFlight; // Replace with your Flight model
  final String departureCity;
  final String departureThumbnail;
  final String arrivalCity;
  final String arrivalThumbnail;
  AddContactsScreenArgs({
    required this.selectedFlight,
    required this.departureCity,
    required this.departureThumbnail,
    required this.arrivalCity,
    required this.arrivalThumbnail,
  });
}

class AddContactsScreen extends StatefulWidget {
  final AddContactsScreenArgs args;
  const AddContactsScreen({Key? key, required this.args}) : super(key: key);

  @override
  State<AddContactsScreen> createState() => _AddContactsScreenState();
}

class _AddContactsScreenState extends State<AddContactsScreen> {
  final List<ContactModel> _selectedContacts = [];

  Future<void> _pickContact() async {
    // Contact picker temporarily disabled for UI testing
    // try {
    //   final FlutterNativeContactPicker contactPicker = FlutterNativeContactPicker();
    //   final Contact? contact = await contactPicker.selectContact();
    //   if (contact != null && contact.fullName != null && contact.phoneNumbers != null && contact.phoneNumbers!.isNotEmpty) {
    //     setState(() {
    //       _selectedContacts.add(ContactModel(
    //         name: contact.fullName!,
    //         phoneNumber: contact.phoneNumbers!.first,
    //         platform: 'WhatsApp', // For now, assume WhatsApp
    //       ));
    //     });
    //   }
    // } catch (e) {
    //   // User cancelled or error
    // }
  }

  void _removeContact(int index) {
    setState(() {
      _selectedContacts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5E7EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF111827)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Add Contacts',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Color(0xFF111827),
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: CityConnectionHeader(
                fromCity: args.departureCity,
                fromThumbnail: args.departureThumbnail,
                toCity: args.arrivalCity,
                toThumbnail: args.arrivalThumbnail,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 18),
              child: Text(
                'Let your loved ones stay in the loop',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 18),
            // Selected contacts
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected contacts',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._selectedContacts.asMap().entries.map((entry) {
                      final i = entry.key;
                      final contact = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildContactTile(contact, i),
                      );
                    }).toList(),
                    // Add Contact button
                    GestureDetector(
                      onTap: _pickContact,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, color: Color(0xFF1F2937)),
                            SizedBox(width: 8),
                            Text(
                              'WhatsApp contact',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Select WhatsApp contact to receive live flight updates',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sticky confirm button
            Container(
              width: double.infinity,
              color: const Color(0xFFE5E7EB),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: 350,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement confirm and track logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Next: Confirm & Start Tracking',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(ContactModel contact, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE5E7EB),
          child: contact.avatar != null
              ? Image.network(contact.avatar!, width: 32, height: 32, fit: BoxFit.cover)
              : const Icon(Icons.person, color: Color(0xFF1F2937)),
        ),
        title: Text(contact.name, style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 16, color: Color(0xFF1F2937))),
        subtitle: Row(
          children: const [
            Icon(Icons.chat_bubble, color: Color(0xFF25D366), size: 18),
            SizedBox(width: 4),
            Text('WhatsApp', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF6B7280))),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
          onPressed: () => _removeContact(index),
        ),
      ),
    );
  }
}

// Custom painter for spiral dotted line
class _SpiralDottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const dashLength = 6.0;
    const gap = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    double angle = 0;
    double radius = 10;
    while (radius < size.width / 2) {
      final x1 = center.dx + radius * math.cos(angle);
      final y1 = center.dy + radius * math.sin(angle);
      angle += dashLength / radius;
      final x2 = center.dx + radius * math.cos(angle);
      final y2 = center.dy + radius * math.sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      angle += gap / radius;
      radius += 0.7;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 