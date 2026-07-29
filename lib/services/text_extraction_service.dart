import '../models/extracted_data.dart';

/// Service to extract structured data from recognized text
class TextExtractionService {
  static final TextExtractionService _instance =
      TextExtractionService._internal();

  factory TextExtractionService() {
    return _instance;
  }

  TextExtractionService._internal();

  /// Main extraction method - identifies and extracts all supported fields
  ExtractedData extractFromText(String text) {
    if (text.isEmpty) {
      return ExtractedData();
    }

    return ExtractedData(
      name: _extractName(text),
      age: _extractAge(text),
      gender: _extractGender(text),
      address: _extractAddress(text),
      phone: _extractPhone(text),
      email: _extractEmail(text),
      dateOfBirth: _extractDateOfBirth(text),
      documentId: _extractDocumentId(text),
      rawText: text,
    );
  }

  String? _extractName(String text) {
    // Try to extract name - more flexible pattern
    final pattern = RegExp(
      r'(?:name|full name|full\s+name|nombre|full_name)\s*:?\s*([a-zA-Z\s\.]+?)(?=\n|age|gender|address|phone|email|$)',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _extractAge(String text) {
    // Make colon optional for better flexibility
    final pattern = RegExp(r'(?:age|edad)\s*:?\s*(\d+)', caseSensitive: false);
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _extractGender(String text) {
    // Make colon optional for better flexibility
    final pattern = RegExp(
      r'(?:gender|sex|género)\s*:?\s*(male|female|other|m|f|o)',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);

    final value = match?.group(1)?.toLowerCase().trim();

    if (value == 'm') {
      return 'Male';
    }
    if (value == 'f') {
      return 'Female';
    }
    if (value == 'o') {
      return 'Other';
    }

    if (value != null && value.isNotEmpty) {
      return value[0].toUpperCase() + value.substring(1);
    }
    return value;
  }

  String? _extractAddress(String text) {
    // More flexible address pattern - handles multiline and variations
    final pattern = RegExp(
      r'(?:address|dirección|location|addr|add)\s*:?\s*([^\n]+(?:\n(?!(?:phone|email|age|gender|name|date|dob|id|document))[^\n]+)*)',
      caseSensitive: false,
      multiLine: true,
    );
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _extractPhone(String text) {
    // Try to extract phone with multiple keywords: phone, tel, teléfono, mobile, number
    // Pattern accepts: digits, letters, +, space, parentheses, hyphens, dots (for alphanumeric numbers like MM19779347)
    // Made colon optional for better flexibility
    final pattern = RegExp(
      r'(?:phone|tel|teléfono|mobile|number|número)\s*:?\s*([a-zA-Z0-9\+\s\(\)\-\.]+?)(?=\n|email|address|$)',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _extractEmail(String text) {
    // Improved email pattern - accepts emails with or without label
    final pattern = RegExp(
      r'(?:email|e-mail|e-address|mail)\s*:?\s*([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,})',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _extractDateOfBirth(String text) {
    // Improved DOB pattern - handles more date formats
    final pattern = RegExp(
      r'(?:dob|date of birth|date ofbirth|nacimiento|fecha|birth date|birthday|birth_date)\s*:?\s*(\d{1,2}[-\/\.]\d{1,2}[-\/\.]\d{2,4})',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  String? _extractDocumentId(String text) {
    // Improved Document ID pattern - makes colon optional, handles more variations
    final pattern = RegExp(
      r'(?:id|document|doc id|identification|documento|ref|reference|ref no|ref_no|doc_id|id no|id_no)\s*:?\s*([a-zA-Z0-9\-\.]{4,})',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);
    return match?.group(1)?.trim();
  }

  ExtractedData mergeData(ExtractedData existing, ExtractedData newer) {
    return ExtractedData(
      name: newer.name?.isNotEmpty ?? false ? newer.name : existing.name,
      age: newer.age?.isNotEmpty ?? false ? newer.age : existing.age,
      gender:
          newer.gender?.isNotEmpty ?? false ? newer.gender : existing.gender,
      address: newer.address?.isNotEmpty ?? false
          ? newer.address
          : existing.address,
      phone: newer.phone?.isNotEmpty ?? false ? newer.phone : existing.phone,
      email: newer.email?.isNotEmpty ?? false ? newer.email : existing.email,
      dateOfBirth: newer.dateOfBirth?.isNotEmpty ?? false
          ? newer.dateOfBirth
          : existing.dateOfBirth,
      documentId: newer.documentId?.isNotEmpty ?? false
          ? newer.documentId
          : existing.documentId,
      rawText:
          newer.rawText?.isNotEmpty ?? false ? newer.rawText : existing.rawText,
    );
  }
}
