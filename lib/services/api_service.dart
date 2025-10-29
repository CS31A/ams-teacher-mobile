// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();
  
  // ==================== AUTH METHODS ====================
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );

      print('Login Status Code: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 401) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refreshEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> logout(String accessToken) async {
    try {
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.logoutEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ==================== INSTRUCTOR METHODS ====================

  /// Get instructor profile
  Future<Map<String, dynamic>> getInstructorProfile() async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated.',
        };
      }

      final url = '${ApiConstants.baseUrl}/api/instructors/profile';
      print('🌐 Fetching instructor profile from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );

      print('📊 Profile Response Status: ${response.statusCode}');
      print('📝 Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in getInstructorProfile: $e');
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }

  /// Update instructor profile
  Future<Map<String, dynamic>> updateInstructorProfile({
    required int instructorId,
    String? email,
    String? firstname,
    String? lastname,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated.',
        };
      }

      final url = '${ApiConstants.baseUrl}/api/instructors/$instructorId';
      print('🌐 Updating instructor profile at: $url');
      
      // Build update body - only include non-null fields
      final Map<String, dynamic> updateData = {};
      if (email != null) updateData['email'] = email;
      if (firstname != null) updateData['firstname'] = firstname;
      if (lastname != null) updateData['lastname'] = lastname;
      
      print('📝 Update data: $updateData');

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );

      print('📊 Update Response Status: ${response.statusCode}');
      print('📝 Update Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'Profile updated successfully',
          'data': data,
        };
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Invalid data',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Instructor not found',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to update profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in updateInstructorProfile: $e');
      return {
        'success': false,
        'error': 'Error: $e',
      };
    }
  }

  // ==================== SECTIONS METHODS ====================

  /// Get all sections/subjects for the logged-in instructor
  /// Groups schedules by section name and shows subjects under each section
  Future<Map<String, dynamic>> getInstructorSections() async {
    try {
      final token = await StorageService.getToken();
      final instructorId = await StorageService.getInstructorId();
      
      print('🔑 Token: ${token != null ? "Present" : "Missing"}');
      print('👤 Instructor ID: $instructorId');
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      // We don't need instructor ID check anymore since /api/schedules uses JWT
      // Remove this check:
      // if (instructorId == null) { ... }

      // Get all schedules for this instructor (JWT-based, no ID needed)
      final url = '${ApiConstants.baseUrl}/api/schedules';
      print('🌐 Fetching instructor schedules from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );

      print('📊 Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> schedules = json.decode(response.body);
        print('🔍 Total schedules received: ${schedules.length}');
        
        if (schedules.isEmpty) {
          print('⚠️ No schedules found for instructor');
          return {
            'success': true,
            'data': {},
          };
        }
        
        // Structure: Section -> [Subjects]
        // We group by Section.Name (BSCS31A, BSBA31C, etc.)
        // Each section contains multiple subjects (from schedules)
        
        final Map<String, List<Map<String, dynamic>>> sectionSubjects = {};
        
        for (var schedule in schedules) {
          print('---Processing Schedule ID: ${schedule['id']}---');
          
          // Extract section info
          var sectionData = schedule['section'];
          if (sectionData == null) {
            print('⏭️ Skipping - No section data');
            continue;
          }
          
          String sectionName = sectionData['name'] ?? 'Unknown';
          int sectionId = sectionData['id'] ?? 0;
          
          print('📝 Section: $sectionName (ID: $sectionId)');
          
          // Initialize section if not exists
          if (!sectionSubjects.containsKey(sectionName)) {
            sectionSubjects[sectionName] = [];
          }
          
          // Extract subject info
          var subjectData = schedule['subject'];
          String subjectName = subjectData?['name'] ?? 'Unknown Subject';
          String subjectCode = subjectData?['code'] ?? 'N/A';
          int subjectId = subjectData?['id'] ?? 0;
          
          print('📚 Subject: $subjectName ($subjectCode)');
          
          // Extract classroom info
          var classroomData = schedule['classroom'];
          String room = classroomData?['name'] ?? '';
          
          // Extract schedule time
          String timeIn = schedule['timeIn'] ?? '';
          String timeOut = schedule['timeOut'] ?? '';
          String dayOfWeek = schedule['dayOfWeek'] ?? '';
          
          String scheduleStr = '';
          if (dayOfWeek.isNotEmpty && timeIn.isNotEmpty && timeOut.isNotEmpty) {
            // Format: "Monday 08:00:00-10:00:00" -> "Monday 08:00-10:00"
            String formattedTimeIn = timeIn.substring(0, 5); // Get HH:MM
            String formattedTimeOut = timeOut.substring(0, 5); // Get HH:MM
            scheduleStr = '$dayOfWeek $formattedTimeIn-$formattedTimeOut';
          }
          
          print('⏰ Schedule: $scheduleStr');
          print('🏫 Room: $room');
          
          // Add subject to section
          sectionSubjects[sectionName]!.add({
            'sectionId': sectionId,
            'sectionName': sectionName,
            'subjectId': subjectId,
            'subjectName': subjectName,
            'subjectCode': subjectCode,
            'name': subjectName, // For display
            'code': subjectCode, // For display
            'schedule': scheduleStr,
            'room': room,
            'scheduleId': schedule['id'],
            'studentCount': 0, // Will be loaded separately
          });
          
          print('✅ Added subject to section');
        }
        
        print('✅ Grouped by section: ${sectionSubjects.keys.length} sections');
        sectionSubjects.forEach((section, subjects) {
          print('  📚 $section: ${subjects.length} subjects');
        });
        
        return {
          'success': true,
          'data': sectionSubjects,
        };
        
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Access denied.',
        };
      } else if (response.statusCode == 404) {
        print('❌ Not Found - No schedules for this instructor');
        return {
          'success': true,
          'data': {},
        };
      } else {
        print('❌ Unexpected status: ${response.statusCode}');
        print('Response: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to load sections: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in getInstructorSections: $e');
      return {
        'success': false,
        'error': e.toString().contains('timeout') 
            ? 'Connection timeout. Please check your internet.'
            : 'Error: $e',
      };
    }
  }

  /// Get students for a specific section
  /// This gets ALL students in a section
  Future<Map<String, dynamic>> getSectionStudents(int sectionId) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      // Use the correct endpoint for getting section students
      final url = '${ApiConstants.baseUrl}/api/sections/$sectionId/all-students';
      print('🌐 Fetching students from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );

      print('📊 Students Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> students = json.decode(response.body);
        
        final processedStudents = students.map((student) {
          return {
            'id': student['id'] ?? 0,
            'email': student['email'] ?? '',
            'isRegular': student['isRegular'] ?? false,
            'userId': student['userId'] ?? '',
            'sectionId': student['sectionId'] ?? 0,
            'studentId': student['id']?.toString() ?? 'N/A',
          };
        }).toList();
        
        print('✅ Processed ${processedStudents.length} students');
        
        return {
          'success': true,
          'data': processedStudents,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Access denied to this section.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Section not found.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load students: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in getSectionStudents: $e');
      return {
        'success': false,
        'error': e.toString().contains('timeout')
            ? 'Connection timeout. Please check your internet.'
            : 'Error: $e',
      };
    }
  }

  /// Get section details
  Future<Map<String, dynamic>> getSectionDetails(int sectionId) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      final url = '${ApiConstants.baseUrl}/api/sections/$sectionId';
      print('🌐 Fetching section details from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        ApiConstants.connectionTimeout,
        onTimeout: () => throw Exception('Connection timeout'),
      );

      print('📊 Section Details Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final section = json.decode(response.body);
        
        return {
          'success': true,
          'data': {
            'id': section['id'] ?? 0,
            'name': section['name'] ?? 'N/A',
            'courseId': section['courseId'] ?? 0,
          },
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Access denied to this section.',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load section details: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💥 Error in getSectionDetails: $e');
      return {
        'success': false,
        'error': e.toString().contains('timeout')
            ? 'Connection timeout. Please check your internet.'
            : 'Error: $e',
      };
    }
  }
}