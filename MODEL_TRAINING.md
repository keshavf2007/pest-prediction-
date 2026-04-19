# Model Training Guide

## 📖 Overview
This guide explains how to create and train a pest detection model using TensorFlow/Keras.

## 🎯 Approach: Transfer Learning with MobileNetV2

We'll use transfer learning because:
- Requires less training data
- Faster training time
- Better accuracy with limited resources
- Lightweight model suitable for mobile deployment

## 📦 Prerequisites

```bash
# Create virtual environment
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # macOS/Linux

# Install dependencies
pip install tensorflow==2.13.1
pip install keras==2.13.1
pip install numpy==1.24.3
pip install pillow==10.0.0
pip install matplotlib
```

## 📊 Dataset Preparation

### Option 1: Use PlantVillage Dataset (Recommended)

1. Download from: https://github.com/spMohanty/PlantVillage-Dataset
2. Extract and organize as:
```
dataset/
├── train/
│   ├── Healthy_Plant/
│   ├── Powdery_Mildew/
│   ├── Early_Blight/
│   └── ... (other classes)
└── val/
    ├── Healthy_Plant/
    ├── Powdery_Mildew/
    ├── Early_Blight/
    └── ... (other classes)
```

### Option 2: Organize Your Own Dataset

Directory structure (minimum 50-100 images per class):
```
my_dataset/
├── train/
│   ├── class_1/
│   ├── class_2/
│   └── ...
└── val/
    ├── class_1/
    ├── class_2/
    └── ...
```

## 🤖 Training Script

Create file: `train_pest_model.py`

```python
"""
Pest Detection Model Training Script
Uses transfer learning with MobileNetV2
"""

import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import (
    Dense, GlobalAveragePooling2D, Dropout
)
from tensorflow.keras.models import Model
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import (
    EarlyStopping, ModelCheckpoint, ReduceLROnPlateau
)
import os
import matplotlib.pyplot as plt

# Configuration
DATASET_PATH = 'dataset'  # Change to your dataset path
IMAGE_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 20
INITIAL_LEARNING_RATE = 0.001

# Verify dataset exists
if not os.path.exists(DATASET_PATH):
    print(f"ERROR: Dataset not found at {DATASET_PATH}")
    print("Please organize your dataset before running training")
    exit(1)

print("🚀 Starting Pest Detection Model Training...")
print(f"📁 Dataset path: {DATASET_PATH}")
print(f"📸 Image size: {IMAGE_SIZE}")
print(f"📊 Batch size: {BATCH_SIZE}")

# ============================================================================
# 1. DATA PREPARATION
# ============================================================================
print("\n📊 Preparing data...")

# Training data augmentation
train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=20,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest',
    validation_split=0.1  # Use 10% for validation if separate folder doesn't exist
)

# Validation data (minimal augmentation)
val_datagen = ImageDataGenerator(rescale=1./255)

# Load training data
train_data = train_datagen.flow_from_directory(
    os.path.join(DATASET_PATH, 'train'),
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    shuffle=True
)

# Load validation data
val_data = val_datagen.flow_from_directory(
    os.path.join(DATASET_PATH, 'val'),
    target_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    shuffle=False
)

num_classes = train_data.num_classes
print(f"✓ Found {num_classes} pest classes")
print(f"  Classes: {', '.join(train_data.class_indices.keys())}")
print(f"  Training samples: {train_data.samples}")
print(f"  Validation samples: {val_data.samples}")

# ============================================================================
# 2. MODEL ARCHITECTURE
# ============================================================================
print("\n🏗️  Building model...")

# Load pre-trained MobileNetV2 (trained on ImageNet)
base_model = MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights='imagenet'
)

# Freeze base model weights
base_model.trainable = False
print("✓ Loaded pre-trained MobileNetV2")
print("✓ Frozen base model layers")

# Add custom layers
inputs = tf.keras.Input(shape=(224, 224, 3))
x = base_model(inputs, training=False)
x = GlobalAveragePooling2D()(x)
x = Dense(256, activation='relu')(x)
x = Dropout(0.5)(x)
x = Dense(128, activation='relu')(x)
x = Dropout(0.3)(x)
outputs = Dense(num_classes, activation='softmax')(x)

model = Model(inputs=inputs, outputs=outputs)

print(f"✓ Added custom layers for {num_classes} classes")

# ============================================================================
# 3. MODEL COMPILATION
# ============================================================================
print("\n⚙️  Compiling model...")

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=INITIAL_LEARNING_RATE),
    loss='categorical_crossentropy',
    metrics=['accuracy', tf.keras.metrics.TopKCategoricalAccuracy(k=3, name='top_3_accuracy')]
)

print("✓ Model compiled")
print("\nModel Summary:")
print(f"  Total parameters: {model.count_params():,}")

# ============================================================================
# 4. CALLBACKS
# ============================================================================
callbacks = [
    # Save best model
    ModelCheckpoint(
        'best_pest_model.h5',
        monitor='val_accuracy',
        save_best_only=True,
        mode='max',
        verbose=1
    ),
    # Stop if no improvement for 5 epochs
    EarlyStopping(
        monitor='val_loss',
        patience=5,
        restore_best_weights=True,
        verbose=1
    ),
    # Reduce learning rate if loss plateaus
    ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=3,
        min_lr=1e-7,
        verbose=1
    ),
]

# ============================================================================
# 5. TRAINING
# ============================================================================
print("\n🎓 Starting training...")
print("=" * 60)

history = model.fit(
    train_data,
    steps_per_epoch=train_data.samples // BATCH_SIZE,
    validation_data=val_data,
    validation_steps=val_data.samples // BATCH_SIZE,
    epochs=EPOCHS,
    callbacks=callbacks,
    verbose=1
)

# ============================================================================
# 6. FINE-TUNING (Optional)
# ============================================================================
print("\n🔧 Fine-tuning base model...")

# Unfreeze last layer of base model
base_model.trainable = True
for layer in base_model.layers[:-30]:  # Freeze all but last 30 layers
    layer.trainable = False

# Recompile with lower learning rate
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=INITIAL_LEARNING_RATE/10),
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# Train again with unfrozen layers
print("Training with fine-tuning for 5 more epochs...")
history_ft = model.fit(
    train_data,
    steps_per_epoch=train_data.samples // BATCH_SIZE,
    validation_data=val_data,
    validation_steps=val_data.samples // BATCH_SIZE,
    epochs=5,
    callbacks=callbacks,
    verbose=1
)

# ============================================================================
# 7. EVALUATION
# ============================================================================
print("\n📈 Evaluating model...")

val_loss, val_accuracy, val_top3 = model.evaluate(val_data, verbose=0)
print(f"Validation Loss: {val_loss:.4f}")
print(f"Validation Accuracy: {val_accuracy:.4f}")
print(f"Top-3 Accuracy: {val_top3:.4f}")

# ============================================================================
# 8. SAVE MODEL
# ============================================================================
print("\n💾 Saving model...")

model.save('pest_model.h5')
print("✓ Model saved as pest_model.h5")
print("  This file should be placed in backend/ directory")

# ============================================================================
# 9. VISUALIZATION
# ============================================================================
print("\n📊 Plotting training history...")

plt.figure(figsize=(12, 4))

# Accuracy plot
plt.subplot(1, 2, 1)
plt.plot(history.history['accuracy'], label='Train Accuracy')
plt.plot(history.history['val_accuracy'], label='Val Accuracy')
plt.title('Model Accuracy')
plt.xlabel('Epoch')
plt.ylabel('Accuracy')
plt.legend()
plt.grid(True)

# Loss plot
plt.subplot(1, 2, 2)
plt.plot(history.history['loss'], label='Train Loss')
plt.plot(history.history['val_loss'], label='Val Loss')
plt.title('Model Loss')
plt.xlabel('Epoch')
plt.ylabel('Loss')
plt.legend()
plt.grid(True)

plt.tight_layout()
plt.savefig('training_history.png')
print("✓ Saved training_history.png")
plt.close()

print("\n" + "=" * 60)
print("✅ Training complete!")
print("=" * 60)
print("\nNext steps:")
print("1. Copy pest_model.h5 to backend/ directory")
print("2. Start Flask backend: python app.py")
print("3. Run Flutter app and test predictions")
```

## 🚀 Running Training

### Step 1: Prepare Dataset
Organize your dataset in the structure mentioned above.

### Step 2: Run Training Script
```bash
python train_pest_model.py
```

### Step 3: Monitor Progress
The script will show:
- Model architecture
- Training progress (accuracy, loss)
- Validation results
- Training time

### Step 4: Use Trained Model
The script creates `pest_model.h5`:
```bash
# Copy to backend
cp pest_model.h5 ../backend/pest_model.h5
```

## 📊 Expected Results

With adequate data and training:
- **Accuracy**: 85-95%
- **Top-3 Accuracy**: 95-99%
- **Training Time**: 10-30 minutes (depending on hardware)
- **Model Size**: ~40-50 MB (H5 format)

## 🔧 Tips for Better Results

### 1. **Data Quality**
- Clean, well-labeled images
- Good lighting and angle
- Consistent image quality
- Multiple perspectives per pest

### 2. **Data Quantity**
- Minimum: 50 images per class
- Better: 200+ images per class
- Best: 500+ images per class

### 3. **Data Balance**
- Similar number of images per class
- Use data augmentation if imbalanced
- Weighted classes if necessary

### 4. **Hyperparameter Tuning**
```python
# Try different values:
BATCH_SIZE = 16  # or 64
EPOCHS = 30
INITIAL_LEARNING_RATE = 0.0001  # Lower = slower but more stable
```

### 5. **Model Variants**
Try different architectures:
```python
# MobileNetV3 (newer, faster)
from tensorflow.keras.applications import MobileNetV3Small

# EfficientNet (better accuracy)
from tensorflow.keras.applications import EfficientNetB0
```

## 🐛 Troubleshooting

### ❌ Out of Memory
```python
# Reduce batch size
BATCH_SIZE = 16  # was 32

# Or reduce image size
IMAGE_SIZE = (160, 160)  # was (224, 224)
```

### ❌ Training Too Slow
- Use GPU: TensorFlow will auto-detect
- Reduce dataset size
- Use MobileNetV3 instead of V2

### ❌ Low Accuracy
- Check dataset quality
- Increase training data
- Tune hyperparameters
- Try different model architecture

### ❌ Model Not Saving
```bash
# Ensure directory exists
mkdir models
# Or save to current directory
model.save('./pest_model.h5')
```

## 📚 Advanced: Custom Dataset

If training on your own images:

```python
# Create train/val split automatically
from sklearn.model_selection import train_test_split
import shutil

# After organizing dataset in single folder, run:
# Then use train/val split script
```

## 🎯 Production Checklist

- [ ] Model saved as `pest_model.h5`
- [ ] Validation accuracy > 85%
- [ ] Tested on new images
- [ ] Model placed in backend/
- [ ] Flask API working
- [ ] Flutter app connecting
- [ ] End-to-end testing complete

---

For more info: [TensorFlow Transfer Learning Guide](https://www.tensorflow.org/tutorials/images/transfer_learning)
