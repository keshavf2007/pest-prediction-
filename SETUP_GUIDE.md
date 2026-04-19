# Complete Setup Guide - Pest Detection Application

## 📋 Table of Contents
1. [Backend Setup](#backend-setup)
2. [Frontend Setup](#frontend-setup)
3. [Model Setup](#model-setup)
4. [Running the Application](#running-the-application)
5. [Troubleshooting](#troubleshooting)

---

## 🔧 Backend Setup

### Step 1: Prerequisites
- Python 3.8 or higher installed
- pip package manager
- Git (optional)

### Step 2: Create Project Directory
```bash
mkdir pest_detection_app
cd pest_detection_app
mkdir backend
cd backend
```

### Step 3: Create Virtual Environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### Step 4: Install Dependencies
```bash
pip install -r requirements.txt
```

**If requirements.txt doesn't exist, install manually:**
```bash
pip install Flask==2.3.3
pip install Flask-CORS==4.0.0
pip install TensorFlow==2.13.1
pip install Keras==2.13.1
pip install Pillow==10.0.0
pip install numpy==1.24.3
```

### Step 5: Verify Installation
```bash
python -c "import tensorflow; print(f'TensorFlow: {tensorflow.__version__}')"
python -c "import flask; print(f'Flask: {flask.__version__}')"
```

### Step 6: Add Model File
1. Ensure you have `pest_model.h5` file
2. Place it in the `backend/` directory (root of Flask app)
3. Path should be: `backend/pest_model.h5`

### Step 7: Start Backend Server
```bash
python app.py
```

**Expected output:**
```
 * Serving Flask app 'app'
 * Debug mode: on
 * Running on http://0.0.0.0:5000
```

✓ Backend is now running!

---

## 📱 Frontend Setup

### Step 1: Prerequisites
- Flutter 3.0+ installed
- Dart 3.0+ (comes with Flutter)
- Android SDK 21+ or iOS 12.0+

### Step 2: Install Flutter
Follow [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

Verify installation:
```bash
flutter --version
dart --version
```

### Step 3: Create Flutter Project
```bash
flutter create pest_detection_app
cd pest_detection_app
```

### Step 4: Get Dependencies
```bash
flutter pub get
```

### Step 5: ⚠️ IMPORTANT - Update Backend URL

Open [lib/services/api_service.dart](lib/services/api_service.dart)

Find this line:
```dart
static const String _baseUrl = 'http://10.0.2.2:5000';
```

Replace with your setup:

**For Android Emulator:**
```dart
static const String _baseUrl = 'http://10.0.2.2:5000';  // Default - connects to host machine
```

**For iOS Simulator:**
```dart
static const String _baseUrl = 'http://localhost:5000';
```

**For Physical Device:**
Find your PC's IP address:
```bash
# Windows - open Command Prompt
ipconfig

# macOS/Linux
ifconfig
```

Look for IPv4 Address (e.g., 192.168.1.100):
```dart
static const String _baseUrl = 'http://192.168.1.100:5000';
```

### Step 6: Test Flutter Installation
```bash
flutter doctor
```

All checks should show green ✓

---

## 🤖 Model Setup

### Option A: Use Pre-trained Model (Quick)

1. Download a pre-trained pest detection model
2. Ensure it's in `.h5` format
3. Place in `backend/` directory as `pest_model.h5`

### Option B: Train Your Own Model

#### Prerequisites
- Python with TensorFlow
- Plant disease dataset (e.g., [PlantVillage Dataset](https://github.com/spMohanty/PlantVillage-Dataset))

#### Training Script

Create `backend/train_model.py`:

```python
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.models import Model
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import os

# Dataset configuration
DATASET_PATH = 'path/to/your/dataset'  # Update this
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 10

# Create data generators
train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest'
)

val_datagen = ImageDataGenerator(rescale=1./255)

# Load training data
train_data = train_datagen.flow_from_directory(
    os.path.join(DATASET_PATH, 'train'),
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical'
)

# Load validation data
val_data = val_datagen.flow_from_directory(
    os.path.join(DATASET_PATH, 'val'),
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical'
)

# Build model using transfer learning
base_model = MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights='imagenet'
)
base_model.trainable = False

# Add custom layers
x = GlobalAveragePooling2D()(base_model.output)
x = Dense(128, activation='relu')(x)
outputs = Dense(train_data.num_classes, activation='softmax')(x)

model = Model(inputs=base_model.input, outputs=outputs)

# Compile
model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

print(model.summary())

# Train
history = model.fit(
    train_data,
    steps_per_epoch=train_data.samples // BATCH_SIZE,
    validation_data=val_data,
    validation_steps=val_data.samples // BATCH_SIZE,
    epochs=EPOCHS,
    verbose=1
)

# Save model
model.save('pest_model.h5')
print("✓ Model saved as pest_model.h5")
```

#### Run Training
```bash
cd backend
python train_model.py
```

---

## 🚀 Running the Application

### Setup Checklist
- [ ] Backend server running (`python app.py` in backend/)
- [ ] `pest_model.h5` in backend directory
- [ ] Backend URL updated in Flutter app
- [ ] Flutter dependencies installed (`flutter pub get`)

### Step 1: Start Backend (Terminal 1)
```bash
cd backend
# Activate virtual environment if not already
venv\Scripts\activate  # Windows
source venv/bin/activate  # macOS/Linux

python app.py
```

**Expected:** Server running at `http://0.0.0.0:5000`

### Step 2: Start Flutter App (Terminal 2)
```bash
cd pest_detection_app
flutter run
```

**For specific device:**
```bash
flutter devices  # List available devices
flutter run -d <device_id>
```

### Step 3: Test Health Check
When app starts, it should show: "✓ Connected to backend"

---

## 🧪 Testing the Application

### Manual Testing

1. **Test Backend Health Check:**
```bash
curl http://localhost:5000/health
```

2. **Test Prediction (Terminal):**
```bash
curl -X POST -F "image=@test_image.jpg" http://localhost:5000/predict
```

3. **Test in App:**
- Tap "Take Photo" or "Choose from Gallery"
- Select a plant image
- Tap "Analyze Plant"
- View results

### Expected Response
```json
{
  "result": "Powdery Mildew",
  "confidence": 95.32,
  "solution": "Apply neem oil spray or sulfur dust...",
  "all_predictions": {...}
}
```

---

## 🆘 Troubleshooting

### Backend Issues

#### ❌ Model Not Loading
```
⚠ Warning: Model file 'pest_model.h5' not found
```

**Solution:**
- [ ] Ensure `pest_model.h5` exists in backend directory
- [ ] Check file is valid Keras model (try: `keras.models.load_model('pest_model.h5')`)
- [ ] Verify TensorFlow version matches

#### ❌ Port Already in Use
```
Address already in use
```

**Solution:**
```bash
# Windows
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# macOS/Linux
lsof -i :5000
kill -9 <PID>
```

#### ❌ Module Import Errors
```
ModuleNotFoundError: No module named 'tensorflow'
```

**Solution:**
```bash
pip install TensorFlow==2.13.1 --upgrade
```

### Flutter Issues

#### ❌ Can't Connect to Backend

1. **Check Backend Running:**
```bash
curl http://localhost:5000/health
```

2. **Check URL Configuration:**
- For Android Emulator: Must be `10.0.2.2` (not `localhost`)
- For iOS Simulator: Can be `localhost`
- For Physical Device: Use actual machine IP

3. **Check Firewall:**
- Windows: Allow Python through firewall
- macOS: Check System Preferences > Security > Firewall

4. **Get Machine IP:**
```bash
# Windows
ipconfig

# macOS/Linux
ifconfig
```

#### ❌ Camera Permission Denied

**Android:**
- Go to Settings > Apps > Pest Detection
- Tap Permissions > Camera > Allow

**iOS:**
- Go to Settings > Pest Detection > Camera > Allow

#### ❌ Build Errors
```bash
flutter pub get
flutter clean
flutter pub get
flutter run
```

#### ❌ Image Upload Fails

- Check image size (max 16MB)
- Try different image format
- Verify network connection
- Check backend logs for errors

### Network Issues

#### ❌ No Internet Connection
- Check WiFi/Mobile data
- Ensure device is on same network as PC (for physical device)
- Test with: `flutter logs`

#### ❌ Request Timeout
- Backend may be slow
- Check backend logs
- Try again
- May need faster server for production

---

## 📊 Performance Tips

1. **Backend:**
   - Use GPU for faster predictions
   - Implement image caching
   - Use Gunicorn for production: `gunicorn -w 4 app:app`

2. **Frontend:**
   - Image is automatically optimized
   - Results cached for 1 analysis session
   - Hot reload during development for faster iteration

---

## ✅ Verification Checklist

After setup:
- [ ] Backend starts without errors
- [ ] Model loads successfully
- [ ] Flutter app connects to backend
- [ ] Can take/select photo
- [ ] Analysis returns results
- [ ] Treatment recommendations display
- [ ] Error handling works

---

## 📚 Additional Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [TensorFlow/Keras Guide](https://www.tensorflow.org/guide)
- [Flutter Documentation](https://flutter.dev/docs)
- [PlantVillage Dataset](https://github.com/spMohanty/PlantVillage-Dataset)

---

**Need Help?**
1. Check error messages carefully
2. Review troubleshooting section
3. Check application logs
4. Ensure all prerequisites are installed

Good luck! 🌱🚀
