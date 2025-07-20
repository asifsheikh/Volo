import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class ProfilePictureService {
  static final ImagePicker _picker = ImagePicker();
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Show image source selection bottom sheet
  static Future<ImageSource?> _showImageSourceSheet(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Update Profile Photo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF008080).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.camera_alt, color: Color(0xFF008080)),
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF008080).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.photo_library, color: Color(0xFF008080)),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pick image from camera or gallery
  static Future<File?> pickImage(BuildContext context) async {
    try {
      final ImageSource? source = await _showImageSourceSheet(context);
      
      if (source == null) {
        return null;
      }

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      
      return null;
    } catch (e) {
      developer.log('ProfilePictureService: Error picking image: $e', name: 'VoloProfile');
      return null;
    }
  }

  /// Upload image to Firebase Storage
  static Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create unique filename
      final String fileName = 'profile_pictures/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Create storage reference
      final Reference storageRef = _storage.ref().child(fileName);
      
      // Upload file
      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      developer.log('ProfilePictureService: Image uploaded successfully: $downloadUrl', name: 'VoloProfile');
      
      return downloadUrl;
    } catch (e) {
      developer.log('ProfilePictureService: Error uploading image: $e', name: 'VoloProfile');
      return null;
    }
  }

  /// Update user profile in Firestore with new profile picture URL
  static Future<bool> updateUserProfilePicture(String imageUrl) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Update user document in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'profilePictureUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      developer.log('ProfilePictureService: Profile picture updated in Firestore', name: 'VoloProfile');
      return true;
    } catch (e) {
      developer.log('ProfilePictureService: Error updating profile picture in Firestore: $e', name: 'VoloProfile');
      return false;
    }
  }

  /// Get user's profile picture URL from Firestore
  static Future<String?> getUserProfilePictureUrl() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists && doc.data() != null) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['profilePictureUrl'] as String?;
      }
      
      return null;
    } catch (e) {
      developer.log('ProfilePictureService: Error getting profile picture URL: $e', name: 'VoloProfile');
      return null;
    }
  }

  /// Complete profile picture update process
  static Future<bool> updateProfilePicture(BuildContext context) async {
    try {
      // Pick image
      final File? imageFile = await pickImage(context);
      if (imageFile == null) {
        return false;
      }

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Updating profile picture...'),
              ],
            ),
          );
        },
      );

      // Upload to Firebase Storage
      final String? imageUrl = await uploadProfilePicture(imageFile);
      if (imageUrl == null) {
        Navigator.of(context).pop(); // Close loading dialog
        throw Exception('Failed to upload image');
      }

      // Update Firestore
      final bool success = await updateUserProfilePicture(imageUrl);
      if (!success) {
        Navigator.of(context).pop(); // Close loading dialog
        throw Exception('Failed to update profile in database');
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Success - no snack bar needed

      return true;
    } catch (e) {
      developer.log('ProfilePictureService: Error in update process: $e', name: 'VoloProfile');
      
      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile picture: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );

      return false;
    }
  }
} 