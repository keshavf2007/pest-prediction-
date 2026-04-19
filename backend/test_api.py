"""
Test Script to verify Pest Detection API
Run this to ensure backend is working correctly
"""

import requests
import json
import sys

# Configuration
BACKEND_URL = "http://localhost:5000"
TIMEOUT = 5

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    END = '\033[0m'

def print_success(msg):
    print(f"{Colors.GREEN}✓ {msg}{Colors.END}")

def print_error(msg):
    print(f"{Colors.RED}✗ {msg}{Colors.END}")

def print_info(msg):
    print(f"{Colors.BLUE}ℹ {msg}{Colors.END}")

def print_warning(msg):
    print(f"{Colors.YELLOW}⚠ {msg}{Colors.END}")

def test_health_check():
    """Test health endpoint"""
    print_info("Testing health endpoint...")
    try:
        response = requests.get(f"{BACKEND_URL}/health", timeout=TIMEOUT)
        if response.status_code == 200:
            data = response.json()
            print_success("Health check passed")
            print(f"  Status: {data.get('status')}")
            print(f"  Message: {data.get('message')}")
            print(f"  Model Status: {data.get('model_status')}")
            return True
        else:
            print_error(f"Health check failed with status {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print_error("Cannot connect to backend")
        print_warning(f"Make sure Flask server is running at {BACKEND_URL}")
        return False
    except Exception as e:
        print_error(f"Health check error: {e}")
        return False

def test_get_classes():
    """Test classes endpoint"""
    print_info("Testing classes endpoint...")
    try:
        response = requests.get(f"{BACKEND_URL}/classes", timeout=TIMEOUT)
        if response.status_code == 200:
            data = response.json()
            classes = data.get('classes', {})
            print_success(f"Found {len(classes)} pest classes")
            
            # Show first 5 classes
            print("  Sample classes:")
            for i, (pest_class, _) in enumerate(list(classes.items())[:5]):
                print(f"    - {pest_class}")
            
            return True
        else:
            print_error(f"Classes endpoint failed with status {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Classes endpoint error: {e}")
        return False

def test_predict_with_file(image_path):
    """Test prediction with an actual image"""
    print_info(f"Testing prediction endpoint with image: {image_path}...")
    try:
        with open(image_path, 'rb') as img_file:
            files = {'image': img_file}
            response = requests.post(
                f"{BACKEND_URL}/predict",
                files=files,
                timeout=TIMEOUT
            )
        
        if response.status_code == 200:
            data = response.json()
            print_success("Prediction successful!")
            print(f"  Detected Pest: {data.get('result')}")
            print(f"  Confidence: {data.get('confidence')}%")
            print(f"  Treatment: {data.get('solution')}")
            return True
        else:
            print_error(f"Prediction failed with status {response.status_code}")
            print(f"  Response: {response.json()}")
            return False
    except FileNotFoundError:
        print_error(f"Image file not found: {image_path}")
        return False
    except Exception as e:
        print_error(f"Prediction error: {e}")
        return False

def main():
    print("\n" + "=" * 60)
    print("Pest Detection API - Test Suite")
    print("=" * 60 + "\n")
    
    print_info(f"Backend URL: {BACKEND_URL}")
    
    # Test 1: Health Check
    print("\n[1/3] Testing Backend Health...")
    health_ok = test_health_check()
    
    if not health_ok:
        print_error("Backend is not responding. Please start the Flask server.")
        print_warning(f"Run: cd backend && python app.py")
        sys.exit(1)
    
    # Test 2: Get Classes
    print("\n[2/3] Testing Classes Endpoint...")
    classes_ok = test_get_classes()
    
    # Test 3: Prediction (optional)
    print("\n[3/3] Testing Prediction Endpoint...")
    image_path = input("Enter path to test image (or press Enter to skip): ").strip()
    
    if image_path:
        predict_ok = test_predict_with_file(image_path)
    else:
        print_info("Skipping prediction test")
        predict_ok = None
    
    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)
    print_success("Health Check") if health_ok else print_error("Health Check")
    print_success("Classes Endpoint") if classes_ok else print_error("Classes Endpoint")
    if predict_ok is not None:
        print_success("Prediction Endpoint") if predict_ok else print_error("Prediction Endpoint")
    
    print("\n✅ All tests passed!" if (health_ok and classes_ok) else "\n❌ Some tests failed")
    print("=" * 60 + "\n")

if __name__ == "__main__":
    main()
