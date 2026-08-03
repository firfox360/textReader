# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-07-29

### Added
- Initial release of TextReder package
- `TextrederService` - Main public API for OCR and data extraction
- `ImageProcessor` - Image to text conversion using Google ML Kit
- `TextExtractor` - Text to structured data extraction using regex
- `ExtractionResult` - Clean return model with extracted data
- `FieldConfig` - Field configuration model
- Automatic type conversion (String, int, double, bool, DateTime)
- JSON-based field configuration
- Error handling with custom exceptions
- Complete documentation and examples
- Support for field management (add, update, remove)
- Pretty print functionality for debugging

### Features
- 📸 Process images with OCR
- 🎯 Extract structured data with regex patterns
- 🔄 Automatic type conversion based on config
- 📊 Returns Map<String, dynamic> with field IDs as keys
- ⚙️ Configuration-driven (field_config.json)
- 🧪 Easy to test and extend

## [Unreleased]

### Planned
- Support for multiple OCR backends
- Batch image processing
- Custom validation functions
- Field grouping and dependencies
- Performance optimizations
