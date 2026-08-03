#!/usr/bin/env dart

/// Auto-generate field_config.json when user runs `flutter pub get`
/// This hook runs automatically after adding the package to pubspec.yaml

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  try {
    print('🔧 Textreder: Setting up field_config.json...');

    // Determine the caller's project path
    // When run as a post-install hook, args[0] is typically the project directory
    final projectPath = args.isNotEmpty ? args[0] : Directory.current.path;
    final assetsDir = Directory('$projectPath/assets');
    final configFile = File('${assetsDir.path}/field_config.json');

    // Create assets directory if it doesn't exist
    if (!assetsDir.existsSync()) {
      assetsDir.createSync(recursive: true);
      print('✅ Created assets/ directory');
    }

    // Skip if config already exists (don't overwrite user's config)
    if (configFile.existsSync()) {
      print('✅ field_config.json already exists, skipping...');
      return;
    }

    // Default field configuration template
    final defaultConfig = {
      'version': '2.0',
      'description': 'Field configuration for TextReader OCR extraction',
      'fields': [
        {
          'id': 'name',
          'content_name': 'name||full name||customer name||applicant name',
          'type': 'String',
          'regex':
              '(?:full\\s*name|customer\\s*name|applicant\\s*name|name)\\s*[:\\-]?\\s*([A-Za-z][A-Za-z\\s\\.\'-]{1,80})',
          'caseSensitive': false,
        },
        {
          'id': 'email',
          'content_name': 'email||e-mail||mail',
          'type': 'String',
          'regex': '([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,})',
          'caseSensitive': false,
        },
        {
          'id': 'phone',
          'content_name':
              'phone||mobile||mobile number||contact||contact number',
          'type': 'String',
          'regex':
              '(?:phone|mobile|contact(?:\\s*number)?|telephone)?\\s*[:\\-]?\\s*((?:\\+\\d{1,3}[\\s-]?)?(?:\\(?\\d{2,5}\\)?[\\s-]?)?\\d(?:[\\d\\s\\-]{6,15}\\d))',
          'caseSensitive': false,
        },
        {
          'id': 'address',
          'content_name': 'address||residence||location',
          'type': 'String',
          'regex':
              '(?:address|residence|location)\\s*[:\\-]?\\s*([\\s\\S]*?)(?=\\n\\s*(?:phone|mobile|email|name|dob|date of birth|age)\\b|\\\$)',
          'caseSensitive': false,
        },
      ],
    };

    // Write the config file
    final jsonString = JsonEncoder.withIndent('  ').convert(defaultConfig);
    await configFile.writeAsString(jsonString);

    print('✅ Created field_config.json with default fields');
    print('📝 Edit assets/field_config.json to customize your fields');
    print(
        '📖 Learn more: https://pub.dev/packages/textreder/INTEGRATION_GUIDE.md');

    // Try to update pubspec.yaml
    _updatePubspec(projectPath);
  } catch (e, stackTrace) {
    print('❌ Error setting up field_config.json: $e');
    if (e is! FileSystemException) {
      print('Stack trace: $stackTrace');
    }
  }
}

/// Update pubspec.yaml to include the assets
void _updatePubspec(String projectPath) async {
  try {
    final pubspecFile = File('$projectPath/pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      print('⚠️  pubspec.yaml not found, skipping update');
      return;
    }

    var content = await pubspecFile.readAsString();

    // Check if already configured
    if (content.contains('- assets/field_config.json')) {
      print('✅ pubspec.yaml already configured');
      return;
    }

    // Add assets section to flutter
    if (content.contains('flutter:')) {
      if (!content.contains('  assets:')) {
        // Add assets section after flutter:
        content = content.replaceFirst(
          'flutter:',
          'flutter:\n  assets:\n    - assets/field_config.json',
        );
      } else {
        // Add to existing assets
        content = content.replaceFirst(
          '  assets:',
          '  assets:\n    - assets/field_config.json',
        );
      }

      await pubspecFile.writeAsString(content);
      print('✅ Updated pubspec.yaml with assets');
    } else {
      // No flutter section, add it
      content += '\nflutter:\n  assets:\n    - assets/field_config.json\n';
      await pubspecFile.writeAsString(content);
      print('✅ Added flutter section to pubspec.yaml');
    }
  } catch (e) {
    print('⚠️  Could not update pubspec.yaml: $e');
    print('Please manually add this to your pubspec.yaml:');
    print('''
flutter:
  assets:
    - assets/field_config.json
''');
  }
}
