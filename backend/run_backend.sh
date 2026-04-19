#!/bin/bash
# Quick Start Script for macOS/Linux - Backend
# This script sets up and runs the Flask backend

echo ""
echo "========================================"
echo "Pest Detection - Backend Setup & Run"
echo "========================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python from https://www.python.org/downloads/"
    exit 1
fi

echo "✓ Python found: $(python3 --version)"

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install/upgrade dependencies
echo "Installing dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo "✓ Dependencies installed"

# Check if model exists
if [ ! -f "pest_model.h5" ]; then
    echo ""
    echo "⚠ WARNING: pest_model.h5 not found in backend directory!"
    echo "Please ensure the model file is placed here before running predictions."
    echo ""
fi

# Start Flask server
echo ""
echo "========================================"
echo "Starting Flask Server..."
echo "========================================"
echo ""
echo "API running at: http://0.0.0.0:5000"
echo ""
echo "Test the API:"
echo "  curl http://localhost:5000/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

python app.py
