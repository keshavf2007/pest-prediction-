import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pest_detection_app/models/prediction_model.dart';
import 'package:pest_detection_app/models/api_exception.dart';
import 'package:pest_detection_app/services/api_service.dart';
import 'package:pest_detection_app/widgets/result_card.dart';
import 'package:pest_detection_app/widgets/loading_indicator.dart';
import 'package:pest_detection_app/widgets/error_widget.dart' as error_widget;

/// Home screen - main UI for pest detection
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variables
  XFile? _selectedImage;
  PredictionModel? _prediction;
  bool _isLoading = false;
  String? _errorMessage;
  String? _errorTitle;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Optional: Check backend connectivity on app start
    _checkBackendConnection();
  }

  /// Check if backend is reachable
  Future<void> _checkBackendConnection() async {
    try {
      await ApiService.healthCheck();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Connected to backend'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠ Backend connection error: $e'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Capture image from camera
  Future<void> _captureImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _prediction = null;
          _errorMessage = null;
          _errorTitle = null;
        });
      }
    } catch (e) {
      _showError('Camera Error', 'Failed to capture image: $e');
    }
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
          _prediction = null;
          _errorMessage = null;
          _errorTitle = null;
        });
      }
    } catch (e) {
      _showError('Gallery Error', 'Failed to pick image: $e');
    }
  }

  /// Send image to backend for prediction
  Future<void> _analyzePlant() async {
    if (_selectedImage == null) {
      _showError('No Image', 'Please select an image first');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _errorTitle = null;
    });

    try {
      final File imageFile = File(_selectedImage!.path);
      final PredictionModel result = await ApiService.predictPest(imageFile);

      setState(() {
        _prediction = result;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      _showError(e.code ?? 'Error', e.message);
    } catch (e) {
      _showError('Prediction Error', 'An unexpected error occurred: $e');
    }
  }

  /// Display error message
  void _showError(String title, String message) {
    setState(() {
      _isLoading = false;
      _errorTitle = title;
      _errorMessage = message;
    });
  }

  /// Clear selected image and results
  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _prediction = null;
      _errorMessage = null;
      _errorTitle = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pest Detection'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  /// Build main body based on state
  Widget _buildBody() {
    // Show error
    if (_errorMessage != null && _selectedImage == null) {
      return error_widget.ErrorWidget(
        title: _errorTitle ?? 'Error',
        message: _errorMessage ?? 'An error occurred',
        onRetry: _clearImage,
        icon: Icons.warning_amber_rounded,
      );
    }

    // Show loading indicator
    if (_isLoading) {
      return const LoadingIndicator(
        message: 'Analyzing plant image...',
      );
    }

    // Show results
    if (_prediction != null) {
      return SingleChildScrollView(
        child: Column(
          children: [
            // Display selected image
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImage!.path),
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Display prediction results
            ResultCard(prediction: _prediction!),

            // Error display if any
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _clearImage,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _captureImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('New Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show initial state with image picker
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display selected image or placeholder
            if (_selectedImage != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco,
                      size: 100,
                      color: Colors.green[300],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Plant Disease Detection',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Take a photo of a plant to detect pests and diseases',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Action buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _captureImage,
                    icon: const Icon(Icons.camera_alt, size: 24),
                    label: const Text(
                      'Take Photo',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image, size: 24),
                    label: const Text(
                      'Choose from Gallery',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      side: BorderSide(color: Colors.green[700]!, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Show analyze button only if image is selected
            if (_selectedImage != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _analyzePlant,
                  icon: const Icon(Icons.search, size: 24),
                  label: const Text(
                    'Analyze Plant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
