# Yonax.99
99Night in Forest Script.LovesNewRage

## File Upload Feature

This repository now includes a web-based file upload application that allows you to upload and manage files.

### Features
- 🌐 Simple and intuitive web interface
- 📁 Support for multiple file types (TXT, PDF, PNG, JPG, JPEG, GIF, DOC, DOCX, ZIP, RAR)
- 📤 Drag and drop file upload
- 📋 View list of uploaded files
- 🔒 16MB maximum file size limit
- ✅ File type validation

### Installation

1. Install Python 3.7 or higher
2. Install the required dependencies:
```bash
pip install -r requirements.txt
```

### Usage

1. Start the Flask application:
```bash
python app.py
```

2. Open your web browser and navigate to:
```
http://localhost:5000
```

3. You can now upload files by:
   - Clicking on the upload area and selecting a file
   - Dragging and dropping a file onto the upload area

4. View your uploaded files in the list below the upload form

### Security Note
The uploaded files are stored in the `uploads/` directory (excluded from git). Make sure to properly secure your server if deploying to production.
