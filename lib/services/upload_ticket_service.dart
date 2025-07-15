import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;

class UploadTicketService {
  static final ImagePicker _imagePicker = ImagePicker();
  static Uint8List? _uploadedFileData;
  static String? _uploadedFileName;

  /// Get the uploaded file data
  static Uint8List? get uploadedFileData => _uploadedFileData;
  
  /// Get the uploaded file name
  static String? get uploadedFileName => _uploadedFileName;

  /// Clear uploaded file data
  static void clearUploadedFile() {
    _uploadedFileData = null;
    _uploadedFileName = null;
  }

  /// Show file source selection bottom sheet (reusing profile picture dialog style)
  static Future<String?> _showFileSourceSheet(BuildContext context) async {
    return await showModalBottomSheet<String>(
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
                const Text(
                  'Upload Ticket',
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
                      color: const Color(0xFF008080).withOpacity(0.1),
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
                  onTap: () => Navigator.of(context).pop('gallery'),
                ),
                ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF008080).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.folder_open, color: Color(0xFF008080)),
                  ),
                  title: const Text(
                    'Choose from Files',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => Navigator.of(context).pop('files'),
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

  /// Pick image from gallery
  static Future<Uint8List?> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );

      if (image != null) {
        final File file = File(image.path);
        final Uint8List bytes = await file.readAsBytes();
        return bytes;
      }
      
      return null;
    } catch (e) {
      developer.log('UploadTicketService: Error picking image from gallery: $e', name: 'VoloUpload');
      return null;
    }
  }

  /// Pick file from file system
  static Future<Uint8List?> _pickFileFromSystem() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final PlatformFile file = result.files.first;
        
        if (file.bytes != null) {
          return file.bytes!;
        } else if (file.path != null) {
          final File fileObj = File(file.path!);
          return await fileObj.readAsBytes();
        }
      }
      
      return null;
    } catch (e) {
      developer.log('UploadTicketService: Error picking file from system: $e', name: 'VoloUpload');
      return null;
    }
  }

  /// Validate file format
  static bool _isValidFileFormat(String fileName) {
    final String extension = fileName.toLowerCase().split('.').last;
    return ['pdf', 'jpg', 'jpeg', 'png'].contains(extension);
  }

  /// Main upload ticket function
  static Future<bool> uploadTicket(BuildContext context) async {
    try {
      // Show file source selection dialog
      final String? source = await _showFileSourceSheet(context);
      
      if (source == null) {
        return false;
      }

      Uint8List? fileData;
      String? fileName;

      // Pick file based on source
      if (source == 'gallery') {
        fileData = await _pickImageFromGallery();
        fileName = 'ticket_image.jpg'; // Default name for gallery images
      } else if (source == 'files') {
        final FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final PlatformFile file = result.files.first;
          
          if (file.bytes != null) {
            fileData = file.bytes!;
            fileName = file.name;
          } else if (file.path != null) {
            final File fileObj = File(file.path!);
            fileData = await fileObj.readAsBytes();
            fileName = file.name;
          }
        }
      }

      // Validate file
      if (fileData == null) {
        return false;
      }

      if (fileName != null && !_isValidFileFormat(fileName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid file (PDF, JPG, or PNG)'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }

      // Store file data
      _uploadedFileData = fileData;
      _uploadedFileName = fileName ?? 'uploaded_file';

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully uploaded ${_uploadedFileName}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      developer.log('UploadTicketService: File uploaded successfully: ${_uploadedFileName}', name: 'VoloUpload');
      return true;

    } catch (e) {
      developer.log('UploadTicketService: Error uploading ticket: $e', name: 'VoloUpload');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      
      return false;
    }
  }
} 