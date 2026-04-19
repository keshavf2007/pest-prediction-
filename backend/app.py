"""
Flask Backend for AI-Based Pest Detection Application
This API accepts images and returns pest predictions using a pre-trained TensorFlow model
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
from tensorflow import keras
import numpy as np
from PIL import Image
import io
import os
from werkzeug.utils import secure_filename

# Initialize Flask app
app = Flask(__name__)
CORS(app)  # Enable CORS for mobile app communication

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif'}
MODEL_PATH = 'pest_model.h5'
IMAGE_SIZE = (224, 224)

# Create uploads folder if it doesn't exist
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Load the pre-trained model globally
try:
    model = keras.models.load_model(MODEL_PATH)
    print(f"✓ Model loaded successfully from {MODEL_PATH}")
except FileNotFoundError:
    print(f"⚠ Warning: Model file '{MODEL_PATH}' not found. Please ensure it exists in the project root.")
    model = None
except Exception as e:
    print(f"⚠ Error loading model: {e}")
    model = None

# Pest classes and their treatment solutions
PEST_SOLUTIONS = {
    "Healthy Plant": "No treatment needed. Continue regular plant care and monitoring.",
    "Powdery Mildew": "Apply neem oil spray or sulfur dust. Improve air circulation around the plant.",
    "Early Blight": "Remove affected leaves. Apply copper fungicide or mancozeb. Ensure proper spacing.",
    "Late Blight": "Apply systemic fungicide like metalaxyl or mancozeb. Remove infected foliage.",
    "Leaf Spot": "Apply fungicides containing copper or sulfur. Remove heavily infected leaves.",
    "Rust": "Apply sulfur-based or copper fungicides. Ensure adequate ventilation.",
    "Downy Mildew": "Apply copper fungicide or mancozeb. Reduce humidity and improve drainage.",
    "Anthracnose": "Apply copper fungicide. Remove infected leaves and prune for better air flow.",
    "Septoria": "Remove infected leaves. Apply fungicides like azoxystrobin or mancozeb.",
    "Spider Mites": "Spray neem oil or insecticidal soap. Increase humidity and water frequently.",
    "Aphids": "Use neem oil, insecticidal soap, or spinosad. Spray water to dislodge pests.",
    "Whiteflies": "Apply yellow sticky traps. Spray neem oil or insecticidal soap weekly.",
    "Caterpillars": "Use Bt (Bacillus thuringiensis) or spinosad spray. Hand-pick if visible.",
    "Beetles": "Apply neem oil or insecticidal soap. Remove plant debris and mulch.",
    "Mealybugs": "Spray neem oil or horticultural soap. Use alcohol-soaked cotton on visible bugs.",
    "Scale Insects": "Apply horticultural oil spray during dormant season. Use neem oil for active pests.",
    "Thrips": "Use spinosad or neem oil spray. Maintain proper irrigation and humidity.",
    "Fungus Gnats": "Allow soil to dry between watering. Apply insecticidal soap if severe.",
}

def allowed_file(filename):
    """Check if the file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def preprocess_image(image_bytes):
    """
    Preprocess image for model prediction
    - Open image from bytes
    - Resize to 224x224
    - Normalize pixel values
    """
    try:
        # Open image from bytes
        image = Image.open(io.BytesIO(image_bytes))
        
        # Convert to RGB if necessary (handle RGBA, grayscale, etc.)
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Resize to model input size
        image = image.resize(IMAGE_SIZE, Image.Resampling.LANCZOS)
        
        # Convert to numpy array
        image_array = np.array(image, dtype=np.float32)
        
        # Normalize to [0, 1] range (if pixel values are 0-255)
        if image_array.max() > 1.0:
            image_array = image_array / 255.0
        
        # Add batch dimension
        image_array = np.expand_dims(image_array, axis=0)
        
        return image_array
    except Exception as e:
        raise ValueError(f"Image preprocessing failed: {str(e)}")

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    model_status = "loaded" if model is not None else "not_loaded"
    return jsonify({
        "status": "ok",
        "message": "Pest Detection API is running",
        "model_status": model_status
    }), 200

@app.route('/predict', methods=['POST'])
def predict():
    """
    Main prediction endpoint
    
    Expected input:
    - Image file via multipart/form-data with key 'image'
    
    Returns:
    - JSON response with pest class, confidence, and treatment solution
    """
    
    # Check if model is loaded
    if model is None:
        return jsonify({
            "error": "Model not loaded",
            "message": "Please ensure pest_model.h5 exists in the backend directory"
        }), 503
    
    # Check if image file is in request
    if 'image' not in request.files:
        return jsonify({
            "error": "No image provided",
            "message": "Please send an image file with key 'image'"
        }), 400
    
    image_file = request.files['image']
    
    # Check if file has a filename
    if image_file.filename == '':
        return jsonify({
            "error": "No file selected",
            "message": "Please select a valid image file"
        }), 400
    
    # Check file extension
    if not allowed_file(image_file.filename):
        return jsonify({
            "error": "Invalid file type",
            "message": f"Allowed formats: {', '.join(ALLOWED_EXTENSIONS)}"
        }), 400
    
    try:
        # Read image bytes
        image_bytes = image_file.read()
        
        # Preprocess image
        processed_image = preprocess_image(image_bytes)
        
        # Make prediction
        predictions = model.predict(processed_image)
        
        # Get class with highest probability
        predicted_class_idx = np.argmax(predictions[0])
        confidence = float(predictions[0][predicted_class_idx]) * 100
        
        # Get class name (depends on your model's class indices)
        # Note: Update this mapping based on your actual model classes
        class_names = list(PEST_SOLUTIONS.keys())
        
        # Ensure we don't exceed the number of classes
        if predicted_class_idx < len(class_names):
            predicted_class = class_names[predicted_class_idx]
        else:
            predicted_class = "Unknown"
        
        # Get treatment solution
        solution = PEST_SOLUTIONS.get(predicted_class, "Consult a local agricultural expert.")
        
        # Return response
        return jsonify({
            "result": predicted_class,
            "confidence": round(confidence, 2),
            "solution": solution,
            "all_predictions": {
                class_names[i]: round(float(predictions[0][i]) * 100, 2)
                for i in range(min(len(class_names), len(predictions[0])))
            }
        }), 200
    
    except ValueError as ve:
        return jsonify({
            "error": "Image processing error",
            "message": str(ve)
        }), 400
    except Exception as e:
        return jsonify({
            "error": "Prediction failed",
            "message": str(e)
        }), 500

@app.route('/classes', methods=['GET'])
def get_classes():
    """Get list of all pest classes and their solutions"""
    return jsonify({
        "classes": PEST_SOLUTIONS
    }), 200

@app.route('/', methods=['GET'])
def index():
    """Root endpoint with API documentation"""
    return jsonify({
        "name": "Pest Detection API",
        "version": "1.0.0",
        "endpoints": {
            "/predict": {
                "method": "POST",
                "description": "Predict pest/disease from image",
                "parameters": "image file (multipart/form-data)"
            },
            "/health": {
                "method": "GET",
                "description": "Health check endpoint"
            },
            "/classes": {
                "method": "GET",
                "description": "Get all pest classes and solutions"
            }
        }
    }), 200

if __name__ == '__main__':
    # Run Flask app
    # For production, use a production server like Gunicorn
    app.run(debug=True, host='0.0.0.0', port=5000)
