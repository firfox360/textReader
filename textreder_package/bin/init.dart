#!/usr/bin/env dart
/// CLI command to initialize Textreder in a Flutter project
/// Usage: dart run textreder:init

import 'dart:io';
import 'dart:convert';

void main(List<String> args) async {
  print('''
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║              🔧 TEXTREDER INITIALIZATION WIZARD                ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
  ''');

  try {
    // Step 1: Create assets directory
    final assetsDir = Directory('assets');
    if (!assetsDir.existsSync()) {
      assetsDir.createSync();
      print('✅ Created assets/ directory');
    } else {
      print('✅ assets/ directory exists');
    }

    // Step 2: Create field_config.json
    final configFile = File('assets/field_config.json');

    if (configFile.existsSync()) {
      print('\n⚠️  field_config.json already exists');
      print('\nWould you like to overwrite it with the template?');
      print('This will replace your current configuration!');

      final input = stdin.readLineSync()?.toLowerCase();
      if (input != 'y' && input != 'yes') {
        print('\n❌ Cancelled - keeping existing configuration');
        return;
      }
    }

    // Create default configuration
    final defaultConfig = {
      'version': '2.0',
      'description': 'Field configuration for Textreder OCR extraction',
      'fields': [
        {
          'id': 'name',
          'content_name': 'name||Name||full name||Full Name',
          'type': 'String',
          'regex':
          '(?:full\\s*name|customer\\s*name|applicant\\s*name|name)\\s*[:\\-]?\\s*([A-Za-z][A-Za-z\\s\\.\'-]{1,80})',
          'caseSensitive': false,
        },
        {
          'id': 'email',
          'content_name': 'email||Email||e-mail||E-mail',
          'type': 'String',
          'regex':
              '(?:email|Email|e-mail|E-mail)\\s*:?\\s*([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})',
          'caseSensitive': false,
        },
        {
          'id': 'phone',
          'content_name': 'phone||Phone||mobile||Mobile||number||Number',
          'type': 'String',
          'regex':
          '(?:phone|mobile|contact(?:\\s*number)?|telephone)?\\s*[:\\-]?\\s*((?:\\+\\d{1,3}[\\s-]?)?(?:\\(?\\d{2,5}\\)?[\\s-]?)?\\d(?:[\\d\\s\\-]{6,15}\\d))',
          'caseSensitive': false,
        },
        {
          'id': 'address',
          'content_name': 'address||Address||location||Location',
          'type': 'String',
          'regex':
              '(?:address|Address|location|Location)\\s*:?\\s*([^\\n]+(?:\\n(?!(?:phone|email|age|name))[^\\n]+)*)',
          'caseSensitive': false,
        },
      ],
    };



    // Write configuration file
    await configFile.writeAsString(
      JsonEncoder.withIndent('  ').convert(defaultConfig),
    );
    print('✅ Created assets/field_config.json');

    // Step 3: Update pubspec.yaml
    print('\n📝 Updating pubspec.yaml...');
    _updatePubspec();

    print('''
╔════════════════════════════════════════════════════════════════╗
║                    ✅ SETUP COMPLETE!                          ║
╚════════════════════════════════════════════════════════════════╝

Your Textreder project is ready! Here's what was created:

📁 assets/field_config.json
   └─ Default field configuration (customize this!)

🔧 pubspec.yaml
   └─ Updated with assets configuration

📖 NEXT STEPS:

1. Edit assets/field_config.json to add your custom fields
2. Initialize TextrederService in your app:

   final textreder = TextrederService(
     configPath: 'assets/field_config.json',
   );
   await textreder.initialize();

3. Start scanning documents!

📚 DOCUMENTATION:
   → Getting Started: https://pub.dev/packages/textreder
   → Configuration: Edit assets/field_config.json
   → Examples: https://pub.dev/packages/textreder/example

🆘 HELP:
   → README: https://pub.dev/packages/textreder/README.md
   → Guide: https://pub.dev/packages/textreder/INTEGRATION_GUIDE.md
  ''');
  } catch (e) {
    print('❌ Error during initialization: $e');
    exit(1);
  }
}

void _updatePubspec() {
  try {
    final pubspecFile = File('pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      print('⚠️  pubspec.yaml not found');
      print('Please create it or ensure you are in a Flutter project');
      return;
    }

    var content = pubspecFile.readAsStringSync();

    // Check if already configured
    if (content.contains('- assets/field_config.json')) {
      print('✅ pubspec.yaml already has assets configured');
      return;
    }

    // Add assets to flutter section
    if (content.contains('flutter:')) {
      if (!content.contains('  assets:')) {
        // Add assets section
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
    } else {
      // Add flutter section
      content += '\nflutter:\n  assets:\n    - assets/field_config.json\n';
    }

    pubspecFile.writeAsStringSync(content);
    print('✅ Updated pubspec.yaml with assets');
  } catch (e) {
    print('⚠️  Could not update pubspec.yaml automatically');
    print('Please manually add this to your pubspec.yaml:');
    print('''
flutter:
  assets:
    - assets/field_config.json
''');
  }
}
