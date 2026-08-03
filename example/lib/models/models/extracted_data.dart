import 'dart:convert';

/// Model to represent extracted data from scanned documents/images
/// Supports flexible field extraction like Name, Age, Gender, Address, Phone, etc.
class ExtractedData {
  String? name;
  String? age;
  String? gender;
  String? address;
  String? phone;
  String? email;
  String? dateOfBirth;
  String? documentId;
  String? rawText;
  DateTime extractedAt;
  Map<String, String>? customFields;

  ExtractedData({
    this.name,
    this.age,
    this.gender,
    this.address,
    this.phone,
    this.email,
    this.dateOfBirth,
    this.documentId,
    this.rawText,
    DateTime? extractedAt,
    this.customFields,
  }) : extractedAt = extractedAt ?? DateTime.now();

  /// Convert ExtractedData to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    // Add fields only if they have values (keeps JSON clean)
    if (name != null && name!.isNotEmpty) json['name'] = name;
    if (age != null && age!.isNotEmpty) json['age'] = age;
    if (gender != null && gender!.isNotEmpty) json['gender'] = gender;
    if (address != null && address!.isNotEmpty) json['address'] = address;
    if (phone != null && phone!.isNotEmpty) json['phone'] = phone;
    if (email != null && email!.isNotEmpty) json['email'] = email;
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) json['dateOfBirth'] = dateOfBirth;
    if (documentId != null && documentId!.isNotEmpty) json['documentId'] = documentId;
    if (rawText != null && rawText!.isNotEmpty) json['rawText'] = rawText;
    
    json['extractedAt'] = extractedAt.toIso8601String();
    
    if (customFields != null && customFields!.isNotEmpty) {
      json['customFields'] = customFields;
    }

    return json;
  }

  /// Create ExtractedData from JSON
  factory ExtractedData.fromJson(Map<String, dynamic> json) {
    return ExtractedData(
      name: json['name'] as String?,
      age: json['age'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      documentId: json['documentId'] as String?,
      rawText: json['rawText'] as String?,
      extractedAt: json['extractedAt'] != null 
          ? DateTime.parse(json['extractedAt'] as String) 
          : DateTime.now(),
      customFields: json['customFields'] != null 
          ? Map<String, String>.from(json['customFields'] as Map) 
          : null,
    );
  }

  /// Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create from JSON string
  factory ExtractedData.fromJsonString(String jsonString) {
    return ExtractedData.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  /// Get all extracted fields as a readable map
  Map<String, String> getAllFields() {
    final Map<String, String> fields = {};
    
    if (name != null && name!.isNotEmpty) fields['Name'] = name!;
    if (age != null && age!.isNotEmpty) fields['Age'] = age!;
    if (gender != null && gender!.isNotEmpty) fields['Gender'] = gender!;
    if (address != null && address!.isNotEmpty) fields['Address'] = address!;
    if (phone != null && phone!.isNotEmpty) fields['Phone'] = phone!;
    if (email != null && email!.isNotEmpty) fields['Email'] = email!;
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) fields['Date of Birth'] = dateOfBirth!;
    if (documentId != null && documentId!.isNotEmpty) fields['Document ID'] = documentId!;
    
    if (customFields != null) {
      fields.addAll(customFields!);
    }
    
    return fields;
  }

  /// Check if any data was extracted
  bool hasData() {
    return name != null && name!.isNotEmpty ||
           age != null && age!.isNotEmpty ||
           gender != null && gender!.isNotEmpty ||
           address != null && address!.isNotEmpty ||
           phone != null && phone!.isNotEmpty ||
           email != null && email!.isNotEmpty ||
           dateOfBirth != null && dateOfBirth!.isNotEmpty ||
           documentId != null && documentId!.isNotEmpty ||
           customFields != null && customFields!.isNotEmpty;
  }

  /// Count how many fields have been extracted
  int getFieldCount() {
    int count = 0;
    if (name != null && name!.isNotEmpty) count++;
    if (age != null && age!.isNotEmpty) count++;
    if (gender != null && gender!.isNotEmpty) count++;
    if (address != null && address!.isNotEmpty) count++;
    if (phone != null && phone!.isNotEmpty) count++;
    if (email != null && email!.isNotEmpty) count++;
    if (dateOfBirth != null && dateOfBirth!.isNotEmpty) count++;
    if (documentId != null && documentId!.isNotEmpty) count++;
    if (customFields != null) count += customFields!.length;
    return count;
  }

  /// Add a custom field
  void addCustomField(String key, String value) {
    customFields ??= {};
    customFields![key] = value;
  }

  /// Clear all data
  void clear() {
    name = null;
    age = null;
    gender = null;
    address = null;
    phone = null;
    email = null;
    dateOfBirth = null;
    documentId = null;
    rawText = null;
    customFields = null;
  }

  @override
  String toString() {
    return 'ExtractedData(name: $name, age: $age, gender: $gender, address: $address, '
           'phone: $phone, email: $email, dateOfBirth: $dateOfBirth, documentId: $documentId, '
           'extractedAt: $extractedAt, customFields: $customFields)';
  }
}
