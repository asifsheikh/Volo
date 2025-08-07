import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as developer;
import 'flight_ticket_extraction_service.dart';
import 'flight_selection_dialog.dart';
import 'package:lottie/lottie.dart';

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

  /// Handle successful ticket extraction with multi-flight support
  static void _handleExtractionSuccess(BuildContext context, Map<String, dynamic> ticketData, TicketExtractionCallback? onSuccess) {
    final String ticketType = ticketData['ticketType'] ?? 'one-way';
    
    // Check if this is a multi-flight ticket
    if (_extractionService.hasMultipleFlights(ticketData)) {
      // Show flight selection dialog
      final List<Map<String, dynamic>> flights = _extractionService.getAllFlights(ticketData);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return FlightSelectionDialog(
            flights: flights,
            ticketType: ticketType,
            originalFlightCount: ticketData['originalFlightCount'], // Pass original count for deduplication info
            onFlightSelected: (selectedFlight) {
              // Success - no snack bar needed
              
              developer.log('UploadTicketService: Flight selected from multi-flight ticket: $selectedFlight', name: 'VoloUpload');
              
              if (onSuccess != null) {
                onSuccess(selectedFlight);
              }
            },
          );
        },
      );
    } else {
      // Single flight ticket (one-way with or without layovers)
      final Map<String, dynamic>? firstFlight = _extractionService.getFirstFlight(ticketData);
      
      if (firstFlight != null) {
        // Success - no snack bar needed
        
        developer.log('UploadTicketService: Flight info extracted successfully: $firstFlight', name: 'VoloUpload');
        
        if (onSuccess != null) {
          onSuccess(firstFlight);
        }
      } else {
        // Fallback: use the first flight from the flights array
        final List<Map<String, dynamic>> flights = _extractionService.getAllFlights(ticketData);
        if (flights.isNotEmpty) {
          // Success - no snack bar needed
          
          developer.log('UploadTicketService: Flight info extracted successfully (fallback): ${flights.first}', name: 'VoloUpload');
          
          if (onSuccess != null) {
            onSuccess(flights.first);
          }
        }
      }
    }
  }

  /// Show file source selection bottom sheet (reusing profile picture dialog style)
  static Future<String?> _showFileSourceSheet(BuildContext context) async {
    return await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
              backgroundColor: AppTheme.cardBackground,
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
                    color: AppTheme.textSecondary,
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

  /// Capture image from camera
  static Future<Uint8List?> _captureImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
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
      developer.log('UploadTicketService: Error capturing image from camera: $e', name: 'VoloUpload');
      return null;
    }
  }

  /// Scan pass using camera
  static Future<bool> scanPass(BuildContext context, {TicketExtractionCallback? onSuccess}) async {
    try {
      // Show camera options dialog first
      final bool? shouldProceed = await _showCameraOptionsDialog(context);
      
      if (shouldProceed != true) {
        return false; // User cancelled
      }

      // Capture image from camera
      final Uint8List? imageData = await _captureImageFromCamera();
      
      if (imageData == null) {
        return false; // User cancelled or camera failed
      }

      // Store file data
      _uploadedFileData = imageData;
      _uploadedFileName = 'scanned_ticket.jpg';

      // Show comprehensive loading dialog and process the image
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _ProcessingTicketDialog(
            fileName: 'scanned_ticket.jpg',
            processingFunction: () async {
              return await _extractionService.extractFlightInfo(imageData, 'scanned_ticket.jpg');
            },
            onSuccess: (ticketData) {
              // Handle extraction success
              _handleExtractionSuccess(context, ticketData, onSuccess);
            },
            onCancel: () {
              // User cancelled the operation
              developer.log('UploadTicketService: User cancelled ticket processing', name: 'VoloUpload');
            },
          );
        },
      );

      return true;

    } catch (e) {
      developer.log('UploadTicketService: Error scanning pass: $e', name: 'VoloUpload');
      
      // Show error dialog
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
                  'Scan Failed',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            content: Text(
              'Failed to scan ticket: ${e.toString()}',
              style: const TextStyle(
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
      return false;
    }
  }

  /// Show camera options dialog
  static Future<bool?> _showCameraOptionsDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF008080).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF008080),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Scan Ticket',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          content: const Text(
            'The camera will open to scan your ticket. You can take a photo and then choose "Use Photo" or "Retake" in the camera app.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: Color(0xFF4B5563),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: AppTheme.primaryButton,
                              child: const Text('Open Camera'),
            ),
          ],
        );
      },
    );
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
            backgroundColor: AppTheme.destructive,
            duration: Duration(seconds: 3),
          ),
        );
        return false;
      }

      // Store file data
      _uploadedFileData = fileData;
      _uploadedFileName = fileName ?? 'uploaded_file';

      // Show comprehensive loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _ProcessingTicketDialog(
            fileName: fileName ?? 'uploaded_file',
            processingFunction: () async {
              if (fileData == null) {
                throw Exception('File data is null');
              }
              return await _extractionService.extractFlightInfo(fileData, fileName ?? 'uploaded_file');
            },
            onSuccess: (ticketData) {
              // Handle multi-flight tickets
              _handleExtractionSuccess(context, ticketData, onSuccess);
            },
            onCancel: () {
              // User cancelled the operation
              developer.log('UploadTicketService: User cancelled ticket processing', name: 'VoloUpload');
            },
          );
        },
      );

      return true;

    } catch (e) {
      developer.log('UploadTicketService: Error uploading ticket: $e', name: 'VoloUpload');
      
      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error dialog
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
                  'Upload Failed',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            content: Text(
              'Failed to upload file: ${e.toString()}',
              style: const TextStyle(
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
      return false;
    }
  }
}



/// Comprehensive loading dialog for ticket processing
class _ProcessingTicketDialog extends StatefulWidget {
  final String fileName;
  final Future<Map<String, dynamic>?> Function() processingFunction;
  final Function(Map<String, dynamic>) onSuccess;
  final Function() onCancel;

  const _ProcessingTicketDialog({
    required this.fileName,
    required this.processingFunction,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<_ProcessingTicketDialog> createState() => _ProcessingTicketDialogState();
}

class _ProcessingTicketDialogState extends State<_ProcessingTicketDialog> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Step status tracking
  int _currentStep = 0;
  bool _isProcessing = true;
  bool _hasFailed = false;
  String? _failureMessage;
  
  final List<ProcessingStep> _processingSteps = [
    ProcessingStep('Validating file format...', 'Validating file format'),
    ProcessingStep('Analyzing ticket content...', 'Analyzing ticket content'),
    ProcessingStep('Extracting flight information...', 'Extracting flight information'),
    ProcessingStep('Processing data...', 'Processing data'),
    ProcessingStep('Finalizing results...', 'Finalizing results'),
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
    _startProcessing();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startProcessing() async {
    try {
      // Step 1: Validating file format
      await _updateStep(0, StepStatus.completed);
      await _updateStep(1, StepStatus.active);
      
      // Step 2: Analyzing ticket content
      await Future.delayed(const Duration(milliseconds: 800));
      await _updateStep(1, StepStatus.completed);
      await _updateStep(2, StepStatus.active);
      
      // Step 3: Extracting flight information (this is where the actual AI processing happens)
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Call the actual processing function
      final result = await widget.processingFunction();
      
      if (result != null) {
        // Success - complete remaining steps
        await _updateStep(2, StepStatus.completed);
        await _updateStep(3, StepStatus.active);
        await Future.delayed(const Duration(milliseconds: 600));
        await _updateStep(3, StepStatus.completed);
        await _updateStep(4, StepStatus.active);
        await Future.delayed(const Duration(milliseconds: 400));
        await _updateStep(4, StepStatus.completed);
        
        // Success - close dialog and populate form
        if (mounted) {
          Navigator.of(context).pop();
          widget.onSuccess(result);
        }
      } else {
        // Failed at extraction step
        await _updateStep(2, StepStatus.failed, 'Failed to extract flight information');
        _handleFailure('Unable to extract flight information from this file. Please make sure you\'ve uploaded a valid flight ticket or boarding pass.');
      }
      
    } catch (e) {
      // Failed at current step
      await _updateStep(_currentStep, StepStatus.failed, e.toString());
      _handleFailure('Processing failed: ${e.toString()}');
    }
  }

  Future<void> _updateStep(int stepIndex, StepStatus status, [String? errorMessage]) async {
    if (mounted) {
      setState(() {
        _processingSteps[stepIndex].status = status;
        _processingSteps[stepIndex].errorMessage = errorMessage;
        _currentStep = stepIndex;
      });
    }
  }

  void _handleFailure(String message) {
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _hasFailed = true;
        _failureMessage = message;
      });
    }
  }

  void _handleCancel() {
    widget.onCancel();
    Navigator.of(context).pop();
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
                    color: _hasFailed 
                      ? const Color(0xFFDC2626).withOpacity(0.1)
                      : const Color(0xFF008080).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _hasFailed ? Icons.error_outline : Icons.upload_file,
                    color: _hasFailed ? const Color(0xFFDC2626) : const Color(0xFF008080),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasFailed ? 'Processing Failed' : 'Processing Ticket',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: _hasFailed ? const Color(0xFFDC2626) : const Color(0xFF111827),
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
            
            // Processing animation or failure icon
            Container(
              width: 80,
              height: 80,
              child: Center(
                child: _hasFailed
                  ? const Icon(
                      Icons.error_outline,
                      color: Color(0xFFDC2626),
                      size: 40,
                    )
                  : Lottie.asset(
                      'assets/animations/file_searching.json',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      repeat: true,
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
                  final ProcessingStep step = entry.value;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStepColor(step.status),
                          ),
                          child: _getStepIcon(step.status),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.displayText,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: step.status == StepStatus.active ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 14,
                                  color: _getStepTextColor(step.status),
                                ),
                              ),
                              if (step.errorMessage != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  step.errorMessage!,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ],
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
              value: _hasFailed ? 0.0 : (_currentStep + 1) / _processingSteps.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _hasFailed ? const Color(0xFFDC2626) : const Color(0xFF008080)
              ),
            ),
            const SizedBox(height: 8),
            
            if (!_hasFailed) ...[
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
            
            if (_hasFailed && _failureMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _failureMessage!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Cancel/OK button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasFailed ? const Color(0xFFDC2626) : const Color(0xFF6B7280),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  _hasFailed ? 'OK' : 'Cancel',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStepColor(StepStatus status) {
    switch (status) {
      case StepStatus.pending:
        return Colors.grey[300]!;
      case StepStatus.active:
        return const Color(0xFF008080);
      case StepStatus.completed:
        return const Color(0xFF10B981);
      case StepStatus.failed:
        return const Color(0xFFDC2626);
    }
  }

  Widget? _getStepIcon(StepStatus status) {
    switch (status) {
      case StepStatus.pending:
        return null;
      case StepStatus.active:
        return const Icon(
          Icons.radio_button_checked,
          color: Colors.white,
          size: 12,
        );
      case StepStatus.completed:
        return const Icon(
          Icons.check,
          color: Colors.white,
          size: 12,
        );
      case StepStatus.failed:
        return const Icon(
          Icons.close,
          color: Colors.white,
          size: 12,
        );
    }
  }

  Color _getStepTextColor(StepStatus status) {
    switch (status) {
      case StepStatus.pending:
        return const Color(0xFF6B7280);
      case StepStatus.active:
        return const Color(0xFF111827);
      case StepStatus.completed:
        return const Color(0xFF10B981);
      case StepStatus.failed:
        return const Color(0xFFDC2626);
    }
  }
}

// Step status enum
enum StepStatus { pending, active, completed, failed }

// Processing step class
class ProcessingStep {
  String displayText;
  String originalText;
  StepStatus status;
  String? errorMessage;

  ProcessingStep(this.originalText, this.displayText, {this.status = StepStatus.pending, this.errorMessage});
} 