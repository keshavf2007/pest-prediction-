@echo off
REM Quick Start Script for Windows - Backend
REM This script sets up and runs the Flask backend

echo.
echo ========================================
echo Pest Detection - Backend Setup & Run
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo ✓ Python found

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
    echo ✓ Virtual environment created
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install/upgrade dependencies
echo Installing dependencies...
pip install -q --upgrade pip
pip install -q -r requirements.txt
echo ✓ Dependencies installed

REM Check if model exists
if not exist "pest_model.h5" (
    echo.
    echo ⚠ WARNING: pest_model.h5 not found in backend directory!
    echo Please ensure the model file is placed here before running predictions.
    echo.
)

REM Start Flask server
echo.
echo ========================================
echo Starting Flask Server...
echo ========================================
echo.
echo API running at: http://0.0.0.0:5000
echo.
echo Test the API:
echo   curl http://localhost:5000/health
echo.
echo Press Ctrl+C to stop the server
echo.

python app.py
