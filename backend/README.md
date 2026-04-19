# Pest Detection API - Backend Documentation

## Overview
Flask-based REST API for AI-powered pest and disease detection in plants. The API accepts plant images and returns pest/disease predictions using a pre-trained TensorFlow/Keras model.

## Requirements
- Python 3.8+
- TensorFlow/Keras
- Flask
- Flask-CORS
- Pillow
- NumPy

## Installation

### 1. Create Virtual Environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS/Linux
python3 -m venv venv
source venv/bin/activate
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Add Pre-trained Model
Place your trained model file `pest_model.h5` in the backend project root directory.

If you don't have a model yet, see the "Creating a Model" section below.

## Running the Server

### Development
```bash
python app.py
```

The API will start at `http://0.0.0.0:5000`

### Production
Use a production WSGI server:
```bash
# Install Gunicorn
pip install gunicorn

# Run with Gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

## API Endpoints

### 1. Health Check
**Endpoint:** `GET /health`

**Response:**
```json
{
  "status": "ok",
  "message": "Pest Detection API is running",
  "model_status": "loaded"
}
```

### 2. Predict Pest
**Endpoint:** `POST /predict`

**Request:**
- Content-Type: multipart/form-data
- Parameter: `image` (binary file)

**Response (Success):**
```json
{
  "result": "Powdery Mildew",
  "confidence": 95.32,
  "solution": "Apply neem oil spray or sulfur dust. Improve air circulation around the plant.",
  "all_predictions": {
    "Healthy Plant": 2.15,
    "Powdery Mildew": 95.32,
    "Early Blight": 1.53,
    ...
  }
}
```

**Response (Error):**
```json
{
  "error": "No image provided",
  "message": "Please send an image file with key 'image'"
}
```

### 3. Get Pest Classes and Solutions
**Endpoint:** `GET /classes`

**Response:**
```json
{
  "classes": {
    "Healthy Plant": "No treatment needed...",
    "Powdery Mildew": "Apply neem oil spray...",
    ...
  }
}
```

## Image Processing Pipeline

1. **File Validation**: Checks file type (png, jpg, jpeg, gif)
2. **Image Loading**: Opens image from bytes using PIL
3. **Format Conversion**: Converts to RGB if necessary
4. **Resizing**: Resizes image to 224x224 pixels
5. **Normalization**: Normalizes pixel values to [0, 1]
6. **Batch Processing**: Adds batch dimension for model input

## Pest Classes Included

The API comes with solutions for these common pests and diseases:
- Healthy Plant
- Powdery Mildew
- Early Blight
- Late Blight
- Leaf Spot
- Rust
- Downy Mildew
- Anthracnose
- Septoria
- Spider Mites
- Aphids
- Whiteflies
- Caterpillars
- Beetles
- Mealybugs
- Scale Insects
- Thrips
- Fungus Gnats

To add more classes, edit the `PEST_SOLUTIONS` dictionary in `app.py`.

## Creating a TensorFlow Model

### Option 1: Using Transfer Learning (Recommended)

```python
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D
from tensorflow.keras.models import Model

# Load pre-trained MobileNetV2
base_model = MobileNetV2(input_shape=(224, 224, 3), include_top=False)
base_model.trainable = False

# Add custom layers
x = GlobalAveragePooling2D()(base_model.output)
x = Dense(128, activation='relu')(x)
outputs = Dense(18, activation='softmax')(x)  # 18 pest classes

model = Model(inputs=base_model.input, outputs=outputs)

# Compile
model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Train (using your dataset)
# model.fit(train_data, train_labels, validation_data=..., epochs=10)

# Save
model.save('pest_model.h5')
```

### Option 2: Using Your Own Dataset

```python
from tensorflow.keras.preprocessing.image import ImageDataGenerator

# Prepare data
train_datagen = ImageDataGenerator(rescale=1./255)
train_data = train_datagen.flow_from_directory(
    'dataset/train',
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical'
)

# Train and save (similar to Option 1)
```

## CORS Configuration

CORS is enabled for all origins by default. For production, modify in `app.py`:

```python
from flask_cors import CORS

# Restrict to specific origins
CORS(app, resources={
    r"/predict": {"origins": ["https://yourmobileapp.com", "https://example.com"]}
})
```

## Error Handling

The API returns appropriate HTTP status codes:
- `200`: Success
- `400`: Bad Request (missing/invalid image)
- `503`: Service Unavailable (model not loaded)
- `500`: Internal Server Error

## Configuration

Edit these in `app.py`:
- `UPLOAD_FOLDER`: Directory for temporary uploads
- `ALLOWED_EXTENSIONS`: Accepted image formats
- `MODEL_PATH`: Path to model file
- `IMAGE_SIZE`: Model input size (default: 224x224)
- `MAX_CONTENT_LENGTH`: Maximum file size (default: 16MB)

## Testing with cURL

```bash
# Test health
curl http://localhost:5000/health

# Test prediction
curl -X POST -F "image=@path/to/image.jpg" http://localhost:5000/predict

# Get classes
curl http://localhost:5000/classes
```

## Troubleshooting

### Model Not Loading
- Ensure `pest_model.h5` exists in project root
- Check file is valid Keras model format
- Verify TensorFlow version compatibility

### CORS Errors
- Check CORS is enabled in Flask
- Verify mobile app URL is whitelisted
- Check browser console for specific error

### Image Processing Errors
- Verify image format is supported
- Check image file is not corrupted
- Ensure image size is reasonable (<16MB)

## Performance Tips

1. Use a GPU-enabled server for faster predictions
2. Implement request caching for repeated images
3. Load model once (already done in code)
4. Consider async task queue for high volume
5. Use CDN for image uploads

## Deployment

### Docker
```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app:app"]
```

### Environment Variables
```bash
FLASK_ENV=production
FLASK_DEBUG=0
```

---
For issues, check logs and ensure all dependencies are installed correctly.
