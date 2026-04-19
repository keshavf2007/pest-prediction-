# Pest Detection Mobile App - Frontend Documentation

## Overview
Flutter mobile application for detecting plant pests and diseases using AI. The app captures plant images via camera or gallery, sends them to a Flask API for analysis, and displays pest detection results with treatment suggestions.

## Features
- 📷 Camera capture and gallery selection
- 🤖 AI-powered pest detection
- 📊 Real-time confidence scores
- 💡 Smart treatment recommendations
- 🎨 Modern, clean UI with Material Design 3
- ⚡ Loading indicators for better UX
- ❌ Comprehensive error handling

## Requirements
- Flutter 3.0+
- Dart 3.0+
- Android SDK 21+ or iOS 12.0+
- Working Flask backend running

## Installation

### 1. Install Flutter
Follow the official [Flutter installation guide](https://flutter.dev/docs/get-started/install)

### 2. Create Flutter Project
```bash
flutter create pest_detection_app
cd pest_detection_app
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Get Packages
```bash
flutter pub add image_picker http flutter_spinkit intl
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── prediction_model.dart # Data model for predictions
│   └── api_exception.dart    # Custom exception class
├── services/
│   └── api_service.dart      # Flask API communication
├── screens/
│   └── home_screen.dart      # Main app screen
└── widgets/
    ├── result_card.dart      # Result display widget
    ├── loading_indicator.dart # Loading animation
    └── error_widget.dart     # Error display widget
```

## Configuration

### Backend URL Setup

⚠️ **IMPORTANT**: Update the backend URL in [lib/services/api_service.dart](lib/services/api_service.dart)

```dart
static const String _baseUrl = 'http://10.0.2.2:5000';  // Android emulator
// OR
static const String _baseUrl = 'http://localhost:5000'; // iOS simulator
// OR
static const String _baseUrl = 'http://<YOUR_MACHINE_IP>:5000'; // Physical device
```

**Finding Your Machine IP:**
- **Windows**: Run `ipconfig` in Command Prompt, look for IPv4 Address
- **macOS/Linux**: Run `ifconfig`, look for inet address

## Running the App

### Android
```bash
# Run on connected device
flutter run

# Run on emulator
flutter emulators launch <emulator_name>
flutter run
```

### iOS
```bash
# Run on simulator
flutter run

# Run on physical device
flutter run -d <device_id>
```

## Key Components

### 1. Main App (`main.dart`)
- Sets up Material Design 3 theme
- Initializes green color scheme
- Configures app-wide styling

### 2. Home Screen (`screens/home_screen.dart`)
- Image selection (camera/gallery)
- Image preview
- API integration
- Result display
- Error handling

### 3. API Service (`services/api_service.dart`)
Handles all backend communication:
- Health check
- Image upload
- Response parsing
- Error handling
- Timeout management

### 4. Result Card (`widgets/result_card.dart`)
Displays prediction results with:
- Pest/disease name
- Confidence percentage
- Visual confidence bar
- Treatment recommendations

### 5. Loading Indicator (`widgets/loading_indicator.dart`)
Shows beautiful loading animation during processing

### 6. Error Widget (`widgets/error_widget.dart`)
Displays error messages with retry options

## API Integration

The app communicates with Flask backend via:
- **Multipart form-data** for image upload
- **JSON** for response parsing
- **HTTP** for network calls
- **30-second timeout** for requests

### Request Flow
```
User Select Image
    ↓
User Taps "Analyze Plant"
    ↓
Show Loading Indicator
    ↓
Send Image to API
    ↓
Parse JSON Response
    ↓
Display Results or Error
```

## Error Handling

The app handles various error scenarios:

| Error | Cause | Solution |
|-------|-------|----------|
| No Image | User didn't select image | Show prompt to select image |
| File Not Found | Image file deleted | Re-select image |
| No Internet | No connectivity | Check network connection |
| Server Error | Backend not running | Start Flask server |
| Timeout | Server taking too long | Check server performance |
| Model Not Loaded | Model file missing | Add pest_model.h5 to backend |
| Invalid Image | Corrupted or unsupported format | Choose different image |

## Debugging

### Enable Debug Logging
```dart
// In api_service.dart
print('DEBUG: Request sent to $_baseUrl/predict');
print('DEBUG: Response: $jsonResponse');
```

### Check Network
```bash
# Test backend connectivity
curl http://<YOUR_IP>:5000/health
```

### View Console Logs
```bash
flutter logs
```

### Hot Reload Development
```bash
# Make changes and press 'r' in terminal
```

## Building for Release

### Android
```bash
flutter build apk
# Output: build/app/outputs/flutter-apk/app-release.apk

# For release on Play Store
flutter build appbundle
```

### iOS
```bash
flutter build ios
# Output: build/ios/iphoneos/Runner.app
```

## Performance Optimization

1. **Image Quality**: App resizes large images automatically
2. **Lazy Loading**: Model loads only once on backend
3. **Efficient Parsing**: JSON parsing optimized
4. **Memory Management**: Images cleared after analysis

## Permissions Required

### Android (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>This app uses camera to capture plant images for pest detection</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app accesses photo library to select plant images</string>
```

## Dependencies Overview

| Package | Purpose | Version |
|---------|---------|---------|
| flutter | Core framework | Latest |
| image_picker | Camera/Gallery | ^1.0.4 |
| http | API calls | ^1.1.0 |
| flutter_spinkit | Loading animation | ^5.2.0 |
| intl | Internationalization | ^0.19.0 |

## Customization

### Change Color Scheme
Edit `main.dart`:
```dart
primaryColor: Colors.green[700],  // Change to your color
```

### Modify UI Text
Edit `home_screen.dart`:
```dart
Text('Custom message here')
```

### Adjust Loading Message
Edit `loading_indicator.dart`:
```dart
message ?? 'Your custom message',
```

## Testing

### Unit Tests
```dart
// test/api_service_test.dart
void main() {
  test('API Service health check', () async {
    expect(await ApiService.healthCheck(), true);
  });
}
```

Run tests:
```bash
flutter test
```

## Troubleshooting

### App won't connect to backend
- [ ] Backend server is running
- [ ] Backend URL is correct in api_service.dart
- [ ] Firewall allows port 5000
- [ ] Machine IP is reachable

### Camera permission denied
- [ ] Grant permissions in app settings
- [ ] Check AndroidManifest.xml/Info.plist
- [ ] Restart app after granting permissions

### Image upload fails
- [ ] File size under 16MB
- [ ] Image format supported (JPG, PNG, GIF)
- [ ] Network connection stable

### App crashes on prediction
- [ ] Backend model file exists
- [ ] Check Flutter logs for details
- [ ] Ensure TensorFlow is installed on backend

## Deployment

1. Update backend URL for production
2. Generate release builds
3. Test on physical devices
4. Submit to app stores

## Next Steps

1. Connect to working Flask backend
2. Add pest_model.h5 to backend
3. Update backend URL in app
4. Test full flow
5. Build and deploy

---

For issues and support, check the official [Flutter documentation](https://flutter.dev/docs) and [image_picker package](https://pub.dev/packages/image_picker).
