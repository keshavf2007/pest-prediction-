# 🌱 Pest Detection Application - Complete Solution

> AI-powered plant pest and disease detection system for farmers using Flutter mobile app and Flask backend.

## 📋 Project Overview

This is a full-stack application that helps farmers detect plant pests and diseases by:
1. **Capturing** plant images via mobile camera
2. **Analyzing** images using AI/Deep Learning
3. **Providing** pest identification and treatment recommendations

Perfect for modern agriculture and precision farming!

## 📁 Project Structure

```
pest_detection_app/
│
├── 📱 pest_detection_app/          # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart               # App entry point
│   │   ├── screens/                # UI screens
│   │   ├── models/                 # Data models
│   │   ├── services/               # API integration
│   │   └── widgets/                # Reusable widgets
│   ├── pubspec.yaml                # Flutter dependencies
│   └── README.md                   # Flutter documentation
│
├── 🔧 backend/                     # Flask API Server
│   ├── app.py                      # Main Flask application
│   ├── pest_model.h5              # Pre-trained TensorFlow model
│   ├── requirements.txt            # Python dependencies
│   └── README.md                   # Backend documentation
│
├── 📖 SETUP_GUIDE.md              # Complete setup instructions
├── 🤖 MODEL_TRAINING.md           # Model training guide
└── README.md                       # This file
```

## ✨ Features

### Mobile App (Flutter)
- 📷 **Camera Integration**: Capture plant images directly
- 🖼️ **Gallery Support**: Select images from device storage
- 🤖 **AI Predictions**: Real-time pest detection
- 📊 **Confidence Scores**: Shows prediction confidence
- 💡 **Smart Solutions**: Treatment recommendations
- 🎨 **Modern UI**: Clean Material Design 3 interface
- ⚡ **Loading Indicators**: Beautiful animations during processing
- ❌ **Error Handling**: Comprehensive error messages

### Backend (Flask + TensorFlow)
- 🚀 **REST API**: Simple HTTP endpoints
- 🔌 **CORS Support**: Mobile app compatibility
- 🤖 **TensorFlow Integration**: Deep learning predictions
- 📸 **Image Processing**: Automatic preprocessing (224x224, normalization)
- 🧠 **18+ Pest Classes**: Pre-configured pest/disease recognition
- 📋 **Treatment Database**: Curated solutions for each pest
- 🔄 **Health Check**: Backend status verification

## 🎯 Quick Start

### Prerequisites
- Flutter 3.0+ ([Install](https://flutter.dev/docs/get-started/install))
- Python 3.8+ ([Install](https://www.python.org/downloads/))
- Git (Optional)

### 5-Minute Setup

1. **Start Backend**
```bash
cd backend
python -m venv venv
venv\Scripts\activate  # Windows
pip install -r requirements.txt
python app.py
```

2. **Start Flutter App** (in new terminal)
```bash
cd pest_detection_app
flutter pub get
flutter run
```

3. **Update Backend URL** (Important!)
- Open `pest_detection_app/lib/services/api_service.dart`
- Change `_baseUrl` to match your setup:
  - Android Emulator: `http://10.0.2.2:5000`
  - Physical Device: `http://<YOUR_PC_IP>:5000`

✅ Done! App is running!

## 📚 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed setup and troubleshooting
- **[MODEL_TRAINING.md](MODEL_TRAINING.md)** - How to train your own model
- **[backend/README.md](backend/README.md)** - Backend API documentation
- **[pest_detection_app/README.md](pest_detection_app/README.md)** - Flutter app documentation

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│      Flutter Mobile App                 │
│  (Image Capture & Display Results)      │
└──────────┬──────────────────────────────┘
           │
           │ HTTP POST
           │ multipart/form-data
           │
┌──────────▼──────────────────────────────┐
│      Flask REST API                     │
│      (http://localhost:5000)            │
└──────────┬──────────────────────────────┘
           │
           ▼
    ┌─────────────────┐
    │ TensorFlow/Keras│
    │  Model          │
    │ (224x224 input) │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────────────┐
    │ Prediction Output       │
    │ - Pest Class (string)   │
    │ - Confidence (float)    │
    │ - Treatment Solution    │
    │ - All Predictions       │
    └─────────────────────────┘
```

## 🔌 API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/` | GET | API info |
| `/health` | GET | Health check |
| `/predict` | POST | Pest prediction |
| `/classes` | GET | Available classes |

## 📊 Supported Pest Classes

1. Healthy Plant
2. Powdery Mildew
3. Early Blight
4. Late Blight
5. Leaf Spot
6. Rust
7. Downy Mildew
8. Anthracnose
9. Septoria
10. Spider Mites
11. Aphids
12. Whiteflies
13. Caterpillars
14. Beetles
15. Mealybugs
16. Scale Insects
17. Thrips
18. Fungus Gnats

## 🧠 Model Information

- **Architecture**: MobileNetV2 (Transfer Learning)
- **Input Size**: 224 × 224 pixels
- **Output**: 18 pest classes with confidence scores
- **File Format**: Keras H5 format
- **File Size**: ~40-50 MB

## 🛠️ Technology Stack

### Frontend
| Tech | Purpose |
|------|---------|
| Flutter | Cross-platform mobile framework |
| Dart | Programming language |
| image_picker | Camera/gallery integration |
| http | HTTP requests |
| flutter_spinkit | Loading animations |

### Backend
| Tech | Purpose |
|------|---------|
| Python | Backend language |
| Flask | Web framework |
| TensorFlow/Keras | Deep learning |
| Pillow | Image processing |
| NumPy | Numerical computing |
| Flask-CORS | Cross-origin support |

## 📱 Supported Platforms

- ✅ **Android** (API 21+)
- ✅ **iOS** (12.0+)
- ✅ **Windows** (Backend server)
- ✅ **macOS** (Backend server)
- ✅ **Linux** (Backend server)

## 🚀 Deployment

### Backend Deployment
```bash
# Using Gunicorn
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app

# Using Docker
docker build -t pest-detection .
docker run -p 5000:5000 pest-detection
```

### Frontend Deployment
```bash
# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios

# Release builds
flutter build apk --release
```

## 📋 Project Checklist

### Setup
- [ ] Python 3.8+ installed
- [ ] Flutter 3.0+ installed
- [ ] Git configured (optional)

### Backend
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] pest_model.h5 obtained/trained
- [ ] Server running on port 5000
- [ ] Health endpoint responding

### Frontend
- [ ] Dependencies installed (`flutter pub get`)
- [ ] Backend URL configured
- [ ] Camera permissions configured
- [ ] App runs on emulator/device

### Testing
- [ ] Backend API responds to requests
- [ ] App connects to backend
- [ ] Image selection works
- [ ] Prediction returns results
- [ ] Error handling works

## 🐛 Common Issues & Solutions

### Backend URL Connection Failed
```
Solution: Check backend URL in lib/services/api_service.dart
- For Android: http://10.0.2.2:5000
- For Physical Device: http://<YOUR_PC_IP>:5000
```

### Camera Permission Denied
```
Solution: Grant permissions in app settings
- Android: Settings > Apps > Pest Detection > Permissions > Camera
- iOS: Settings > Pest Detection > Camera
```

### Model File Not Found
```
Solution: Ensure pest_model.h5 is in backend/ directory
- Check file exists: ls backend/pest_model.h5
- File should be at: backend/pest_model.h5
```

### Port Already in Use
```
Solution: Kill process using port 5000
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# macOS/Linux
lsof -i :5000
kill -9 <PID>
```

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed troubleshooting.

## 📈 Performance

- **Prediction Time**: 2-5 seconds (backend)
- **App Responsiveness**: <100ms UI updates
- **Model Size**: 40-50 MB
- **Memory Usage**: 200-300 MB (app) + 500 MB (backend)

## 🔒 Security

- ✅ Image validation on backend
- ✅ File type checking
- ✅ Size limits (16 MB max)
- ✅ CORS configuration for production
- ✅ Input sanitization

## 📞 Support & Contribution

For issues:
1. Check [SETUP_GUIDE.md](SETUP_GUIDE.md) troubleshooting
2. Review backend logs: `flutter logs`
3. Verify setup with cURL: `curl http://localhost:5000/health`

## 📄 License

This project is provided as-is for educational and agricultural purposes.

## 🙏 Acknowledgments

- TensorFlow/Keras community
- Flutter framework
- PlantVillage dataset
- Open source contributors

## 🌟 Future Enhancements

- [ ] Offline model support
- [ ] Multiple image analysis
- [ ] Pest history tracking
- [ ] Weather-based recommendations
- [ ] Multi-language support
- [ ] Web dashboard
- [ ] Disease progression tracking

---

## 📚 Quick Links

- [Flutter Setup Guide](SETUP_GUIDE.md#flutter-setup)
- [Backend Setup Guide](SETUP_GUIDE.md#backend-setup)
- [Model Training Guide](MODEL_TRAINING.md)
- [Backend Documentation](backend/README.md)
- [App Documentation](pest_detection_app/README.md)

---

**Ready to detect pests? Start with [SETUP_GUIDE.md](SETUP_GUIDE.md)!** 🚀

Last Updated: April 2026
