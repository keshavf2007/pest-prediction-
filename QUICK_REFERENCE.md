# Quick Reference Guide

## 🚀 30-Second Start (if everything is set up)

### Windows
```bash
# Terminal 1 - Backend
cd backend
run_backend.bat

# Terminal 2 - App  
cd pest_detection_app
flutter run
```

### macOS/Linux
```bash
# Terminal 1 - Backend
cd backend
./run_backend.sh

# Terminal 2 - App
cd pest_detection_app
flutter run
```

---

## 📋 Pre-Setup Checklist

- [ ] Python 3.8+ installed
- [ ] Flutter 3.0+ installed
- [ ] pest_model.h5 file obtained
- [ ] Git (optional)

---

## 📁 File Organization

```
hackathon/
├── backend/
│   ├── app.py
│   ├── pest_model.h5          ← Add your model here!
│   ├── requirements.txt
│   └── run_backend.bat
├── pest_detection_app/
│   ├── lib/
│   ├── pubspec.yaml
│   └── setup_app.bat
├── SETUP_GUIDE.md
├── MODEL_TRAINING.md
└── README.md
```

---

## 🔑 Critical Configuration

### Backend URL in Flutter

**File:** `pest_detection_app/lib/services/api_service.dart`

**Line:** ~17

Change `_baseUrl` based on your setup:

```dart
// Android Emulator (DEFAULT)
static const String _baseUrl = 'http://10.0.2.2:5000';

// iOS Simulator
static const String _baseUrl = 'http://localhost:5000';

// Physical Device (Replace with your PC IP)
static const String _baseUrl = 'http://192.168.1.100:5000';
```

**Finding Your IP:**
```bash
# Windows
ipconfig
# Look for: IPv4 Address: 192.168.x.x

# macOS/Linux
ifconfig
# Look for: inet 192.168.x.x
```

---

## 🛠️ Essential Commands

### Backend

```bash
# Setup
cd backend
python -m venv venv
venv\Scripts\activate              # Windows
source venv/bin/activate           # macOS/Linux
pip install -r requirements.txt

# Run
python app.py

# Test
python test_api.py
curl http://localhost:5000/health

# Run with Gunicorn (Production)
pip install gunicorn
gunicorn -w 4 app:app
```

### Frontend

```bash
# Setup
cd pest_detection_app
flutter pub get
flutter doctor -v

# Run
flutter run

# Run on specific device
flutter devices
flutter run -d <device_id>

# Build Release
flutter build apk --release
flutter build ios --release

# Clean
flutter clean
flutter pub get
flutter run
```

---

## 📦 Dependency Versions

### Python (backend/requirements.txt)
```
Flask==2.3.3
Flask-CORS==4.0.0
TensorFlow==2.13.1
Keras==2.13.1
Pillow==10.0.0
numpy==1.24.3
Werkzeug==2.3.7
```

### Flutter (pest_detection_app/pubspec.yaml)
```yaml
dependencies:
  flutter: sdk: flutter
  image_picker: ^1.0.4
  http: ^1.1.0
  flutter_spinkit: ^5.2.0
  intl: ^0.19.0
```

---

## 🧪 Testing Endpoints

### Health Check
```bash
curl http://localhost:5000/health
```

### Get Classes
```bash
curl http://localhost:5000/classes
```

### Predict (using cURL)
```bash
curl -X POST -F "image=@path/to/image.jpg" \
  http://localhost:5000/predict
```

### Predict (using Python)
```python
import requests

with open('image.jpg', 'rb') as img:
    files = {'image': img}
    response = requests.post('http://localhost:5000/predict', files=files)
    print(response.json())
```

---

## ⚠️ Common Issues & Quick Fixes

| Issue | Fix |
|-------|-----|
| "No module named tensorflow" | `pip install tensorflow==2.13.1` |
| "flutter: command not found" | Add Flutter to PATH |
| "Can't connect to backend" | Check URL in api_service.dart |
| "Camera permission denied" | Grant in app settings |
| "Port 5000 already in use" | `lsof -i :5000` then `kill -9 <PID>` |
| "Model file not found" | Add pest_model.h5 to backend/ |

---

## 📊 Expected Behavior

### Backend
```
✓ Server starts
✓ Model loads (if file exists)
✓ API responds to health check
✓ Accepts image files
✓ Returns predictions
```

### App
```
✓ Shows home screen
✓ "Connected to backend" message
✓ Camera button works
✓ Can select from gallery
✓ Shows loading indicator
✓ Displays results or errors
```

---

## 🎯 Project Files Reference

| File | Purpose | Edit? |
|------|---------|-------|
| app.py | Flask API | No |
| pest_model.h5 | AI Model | ADD THIS |
| main.dart | App entry | No |
| api_service.dart | API client | YES - URL |
| home_screen.dart | Main UI | No |
| requirements.txt | Python deps | No |
| pubspec.yaml | Flutter deps | No |

---

## 📞 Getting Help

1. **Check Setup Guide**: [SETUP_GUIDE.md](SETUP_GUIDE.md)
2. **Check Model Guide**: [MODEL_TRAINING.md](MODEL_TRAINING.md)
3. **Backend Logs**: Look at terminal output
4. **Flutter Logs**: `flutter logs`
5. **Test Backend**: `python backend/test_api.py`

---

## ✅ Success Indicators

- [ ] Backend running without errors
- [ ] App shows "Connected to backend"
- [ ] Can capture/select photos
- [ ] Predictions return in 2-5 seconds
- [ ] Results display correctly
- [ ] No crashes or errors

---

## 🚀 Next Steps

1. **Setup Backend** → Run: `backend/run_backend.bat`
2. **Update App URL** → Edit: `api_service.dart`
3. **Setup App** → Run: `pest_detection_app/setup_app.bat`
4. **Run App** → `flutter run`
5. **Test** → Take a photo and analyze!

---

**Pro Tips:**
- Keep backend and app terminals open side-by-side
- Use `flutter hot reload` (press 'r') for faster development
- Test API with `curl` before using app
- Check internet connection if app can't connect
- Use physical device for better testing

---

Last Updated: April 2026
