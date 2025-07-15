import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import '../features/add_flight/flight_ticket_extraction_service.dart';

/// Callback type for successful ticket extraction
typedef TicketExtractionCallback = void Function(Map<String, dynamic> flightData);

class UploadTicketService {
  static final ImagePicker _imagePicker = ImagePicker();
  static final FlightTicketExtractionService _extractionService = FlightTicketExtractionService();
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

  /// Main upload ticket function with AI extraction
  static Future<bool> uploadTicket(BuildContext context, {TicketExtractionCallback? onSuccess}) async {
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

      // Show comprehensive loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _ProcessingTicketDialog(
            fileName: fileName ?? 'uploaded_file',
          );
        },
      );

      // Store file data
      _uploadedFileData = fileData;
      _uploadedFileName = fileName ?? 'uploaded_file';

      // Extract flight information using AI
      final Map<String, dynamic>? flightData = await _extractionService.extractFlightInfo(fileData, fileName ?? 'uploaded_file');

      // Close loading dialog
      Navigator.of(context).pop();

      if (flightData != null) {
        // Success - populate form fields
        if (onSuccess != null) {
          onSuccess(flightData);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully extracted flight information from ${_uploadedFileName}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        developer.log('UploadTicketService: Flight info extracted successfully: $flightData', name: 'VoloUpload');
        return true;

      } else {
        // Show error dialog for failed extraction
        _showExtractionErrorDialog(context);
        return false;
      }

    } catch (e) {
      developer.log('UploadTicketService: Error uploading ticket: $e', name: 'VoloUpload');
      
      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error dialog
      _showExtractionErrorDialog(context);
      return false;
    }
  }

  /// Show error dialog for failed ticket extraction
  static void _showExtractionErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 24),
              SizedBox(width: 8),
              Text(
                'Failed to Parse Ticket',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          content: const Text(
            'We couldn\'t extract flight information from this file. Please make sure you\'ve uploaded a valid flight ticket or boarding pass.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF4B5563),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF008080),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Comprehensive loading dialog for ticket processing
class _ProcessingTicketDialog extends StatefulWidget {
  final String fileName;

  const _ProcessingTicketDialog({required this.fileName});

  @override
  State<_ProcessingTicketDialog> createState() => _ProcessingTicketDialogState();
}

class _ProcessingTicketDialogState extends State<_ProcessingTicketDialog> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentStep = 0;
  final List<String> _processingSteps = [
    'Validating file format...',
    'Analyzing ticket content...',
    'Extracting flight information...',
    'Processing data...',
    'Finalizing results...',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _startProcessingSteps();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startProcessingSteps() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _currentStep = 1;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _currentStep = 2;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _currentStep = 3;
        });
      }
    });

    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        setState(() {
          _currentStep = 4;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with file name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF008080).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.upload_file,
                    color: Color(0xFF008080),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Processing Ticket',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.fileName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Processing animation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF008080).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Processing steps
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: _processingSteps.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String step = entry.value;
                  final bool isActive = index == _currentStep;
                  final bool isCompleted = index < _currentStep;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted 
                              ? const Color(0xFF10B981)
                              : isActive 
                                ? const Color(0xFF008080)
                                : Colors.grey[300],
                          ),
                          child: isCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              )
                            : isActive
                              ? const Icon(
                                  Icons.radio_button_checked,
                                  color: Colors.white,
                                  size: 12,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            step,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              fontSize: 14,
                              color: isActive 
                                ? const Color(0xFF111827)
                                : isCompleted
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _processingSteps.length,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
            ),
            const SizedBox(height: 8),
            
            Text(
              '${_currentStep + 1} of ${_processingSteps.length} steps',
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
    );
  }
} 