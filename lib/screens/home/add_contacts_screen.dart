import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'dart:math' as math;
import 'city_connection_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'confirmation_screen.dart';

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
  final List<ContactModel> _selectedContacts = [
    ContactModel(
      name: 'Sarah Johnson',
      avatar: 'dummy1', // Use SVG 1
      platform: 'WhatsApp',
      phoneNumber: '+1 555-1234',
    ),
    ContactModel(
      name: 'Michael Chen',
      avatar: 'dummy2', // Use SVG 2
      platform: 'WhatsApp',
      phoneNumber: '+1 555-5678',
    ),
  ];

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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ConfirmationScreen(
                          fromCity: args.departureCity,
                          toCity: args.arrivalCity,
                          contactNames: _selectedContacts.map((c) => c.name).toList(),
                          contactAvatars: _selectedContacts.map((c) => c.avatar == 'dummy1' ? 'assets/dummy1.png' : 'assets/dummy2.png').toList(),
                        ),
                      ),
                    );
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
                        'Next',
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
    String? assetAvatar;
    if (contact.avatar == 'dummy1') {
      assetAvatar = 'assets/dummy1.png';
    } else if (contact.avatar == 'dummy2') {
      assetAvatar = 'assets/dummy2.png';
    }
    const String whatsappSvg = '''<svg width="11" height="12" viewBox="0 0 11 12" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8.92734 2.27578C7.94531 1.29141 6.6375 0.75 5.24766 0.75C2.37891 0.75 0.0445312 3.08437 0.0445312 5.95312C0.0445312 6.86953 0.283594 7.76484 0.738281 8.55469L0 11.25L2.75859 10.5258C3.51797 10.9406 4.37344 11.1586 5.24531 11.1586H5.24766C8.11406 11.1586 10.5 8.82422 10.5 5.95547C10.5 4.56563 9.90937 3.26016 8.92734 2.27578ZM5.24766 10.282C4.46953 10.282 3.70781 10.0734 3.04453 9.67969L2.8875 9.58594L1.25156 10.0148L1.6875 8.41875L1.58437 8.25469C1.15078 7.56563 0.923438 6.77109 0.923438 5.95312C0.923438 3.56953 2.86406 1.62891 5.25 1.62891C6.40547 1.62891 7.49062 2.07891 8.30625 2.89687C9.12187 3.71484 9.62344 4.8 9.62109 5.95547C9.62109 8.34141 7.63125 10.282 5.24766 10.282ZM7.61953 7.04297C7.49063 6.97734 6.85078 6.66328 6.73125 6.62109C6.61172 6.57656 6.525 6.55547 6.43828 6.68672C6.35156 6.81797 6.10313 7.10859 6.02578 7.19766C5.95078 7.28438 5.87344 7.29609 5.74453 7.23047C4.98047 6.84844 4.47891 6.54844 3.975 5.68359C3.84141 5.45391 4.10859 5.47031 4.35703 4.97344C4.39922 4.88672 4.37812 4.81172 4.34531 4.74609C4.3125 4.68047 4.05234 4.04063 3.94453 3.78047C3.83906 3.52734 3.73125 3.5625 3.65156 3.55781C3.57656 3.55313 3.48984 3.55313 3.40312 3.55313C3.31641 3.55313 3.17578 3.58594 3.05625 3.71484C2.93672 3.84609 2.60156 4.16016 2.60156 4.8C2.60156 5.43984 3.06797 6.05859 3.13125 6.14531C3.19688 6.23203 4.04766 7.54453 5.35312 8.10938C6.17812 8.46562 6.50156 8.49609 6.91406 8.43516C7.16484 8.39766 7.68281 8.12109 7.79062 7.81641C7.89844 7.51172 7.89844 7.25156 7.86563 7.19766C7.83516 7.13906 7.74844 7.10625 7.61953 7.04297Z" fill="#6B7280"/></svg>''';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: assetAvatar != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(assetAvatar, width: 40, height: 40, fit: BoxFit.cover),
              )
            : const CircleAvatar(radius: 20, backgroundColor: Color(0xFFE5E7EB)),
        title: Text(
          contact.name,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 18,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Row(
          children: [
            SvgPicture.string(whatsappSvg, width: 16, height: 16),
            const SizedBox(width: 4),
            const Text('WhatsApp', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400, fontSize: 15, color: Color(0xFF6B7280))),
          ],
        ),
        trailing: InkWell(
          onTap: () => _removeContact(index),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 24),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minVerticalPadding: 0,
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