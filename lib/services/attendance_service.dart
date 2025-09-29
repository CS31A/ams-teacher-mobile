import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/attendance.dart';

class AttendanceService {
  static const String csvHeader = 'Student ID,Student Name,Date,Time In,Time Out,Status';

  // Export attendance records to CSV
  static Future<String?> exportToCSV(List<AttendanceRecord> records) async {
    try {
      // Create CSV content
      List<List<dynamic>> csvData = [];
      
      // Add header
      csvData.add(csvHeader.split(','));
      
      // Add data rows
      for (var record in records) {
        csvData.add(record.toCSVRow());
      }
      
      // Convert to CSV string
      String csvContent = const ListToCsvConverter().convert(csvData);
      
      // Get downloads directory
      Directory? directory = await getDownloadsDirectory();
      if (directory == null) {
        // Fallback to documents directory
        directory = await getApplicationDocumentsDirectory();
      }
      
      // Create filename with timestamp
      String fileName = 'attendance_${DateTime.now().millisecondsSinceEpoch}.csv';
      String filePath = '${directory.path}/$fileName';
      
      // Write file
      File file = File(filePath);
      await file.writeAsString(csvContent);
      
      return filePath;
    } catch (e) {
      print('Error exporting CSV: $e');
      return null;
    }
  }

  // Import attendance records from CSV
  static Future<List<AttendanceRecord>> importFromCSV() async {
    try {
      // Pick CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      // Read file content
      String fileContent = result.files.first.bytes != null
          ? String.fromCharCodes(result.files.first.bytes!)
          : await File(result.files.first.path!).readAsString();

      // Parse CSV
      List<List<dynamic>> csvData = const CsvToListConverter().convert(fileContent);

      if (csvData.isEmpty) {
        throw Exception('CSV file is empty');
      }

      // Skip header row and convert to AttendanceRecord objects
      List<AttendanceRecord> records = [];
      for (int i = 1; i < csvData.length; i++) {
        try {
          List<String> row = csvData[i].map((e) => e.toString()).toList();
          AttendanceRecord record = AttendanceRecord.fromCSVRow(row);
          records.add(record);
        } catch (e) {
          print('Error parsing row $i: $e');
          // Skip invalid rows
        }
      }

      return records;
    } catch (e) {
      print('Error importing CSV: $e');
      rethrow;
    }
  }

  // Generate sample CSV data for testing
  static String generateSampleCSV() {
    List<List<dynamic>> csvData = [];
    
    // Add header
    csvData.add(csvHeader.split(','));
    
    // Add sample data
    List<String> sampleData = [
      'STU001,John Doe,2024-01-15,08:30,16:30,Present',
      'STU002,Jane Smith,2024-01-15,08:45,16:45,Late',
      'STU003,Bob Johnson,2024-01-15,08:25,16:25,Present',
      'STU004,Alice Brown,2024-01-15,,,Absent',
      'STU005,Charlie Wilson,2024-01-15,08:35,16:35,Late',
    ];
    
    for (String data in sampleData) {
      csvData.add(data.split(','));
    }
    
    return const ListToCsvConverter().convert(csvData);
  }

  // Save sample CSV file for testing
  static Future<String?> saveSampleCSV() async {
    try {
      Directory? directory = await getDownloadsDirectory();
      if (directory == null) {
        directory = await getApplicationDocumentsDirectory();
      }
      
      String fileName = 'sample_attendance.csv';
      String filePath = '${directory.path}/$fileName';
      
      File file = File(filePath);
      await file.writeAsString(generateSampleCSV());
      
      return filePath;
    } catch (e) {
      print('Error saving sample CSV: $e');
      return null;
    }
  }

  // Validate CSV format
  static bool validateCSVFormat(List<List<dynamic>> csvData) {
    if (csvData.isEmpty) return false;
    
    // Check if header matches expected format
    List<String> header = csvData[0].map((e) => e.toString()).toList();
    List<String> expectedHeader = csvHeader.split(',');
    
    if (header.length != expectedHeader.length) return false;
    
    for (int i = 0; i < expectedHeader.length; i++) {
      if (header[i].trim() != expectedHeader[i]) return false;
    }
    
    return true;
  }

  // Get CSV template as string
  static String getCSVTemplate() {
    return csvHeader + '\n' +
        'STU001,John Doe,2024-01-15,08:30,16:30,Present\n' +
        'STU002,Jane Smith,2024-01-15,08:45,16:45,Late\n' +
        'STU003,Bob Johnson,2024-01-15,08:25,16:25,Present';
  }
}

