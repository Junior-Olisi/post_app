#!/usr/bin/env dart

import 'dart:io';

/// Filters out generated files from coverage report
/// Removes .freezed.dart and .g.dart files from lcov.info
void main(List<String> args) {
  final coverageDir = args.isNotEmpty ? args[0] : '.';
  final lcovFile = File('$coverageDir/lcov.info');

  if (!lcovFile.existsSync()) {
    print('Error: lcov.info not found in $coverageDir');
    exit(1);
  }

  // Read the original file
  final content = lcovFile.readAsStringSync();

  // Split into records (each ends with end_of_record)
  final records = content.split('end_of_record\n');

  // Filter out generated files
  final filtered = records.where((record) {
    if (record.trim().isEmpty) return true;

    final lines = record.split('\n');
    for (final line in lines) {
      if (line.startsWith('SF:')) {
        final filePath = line.substring(3);
        // Exclude .freezed.dart and .g.dart files
        if (filePath.endsWith('.freezed.dart') || filePath.endsWith('.g.dart')) {
          return false;
        }
      }
    }
    return true;
  }).toList();

  // Rebuild the file
  final newContent = filtered.where((r) => r.trim().isNotEmpty).join('end_of_record\n').replaceAll('end_of_recordend_of_record', 'end_of_record');

  // Write back with proper formatting
  lcovFile.writeAsStringSync('${newContent.trim()}\nend_of_record\n');

  print('✓ Coverage report filtered successfully');
  print('✓ Excluded: *.freezed.dart and *.g.dart files');
}
