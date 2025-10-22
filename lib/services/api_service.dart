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
  
  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
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

  // ==================== SECTIONS METHODS ====================

  /// Get all sections for the logged-in instructor
  Future<Map<String, dynamic>> getInstructorSections() async {
    try {
      final token = await StorageService.getToken();
      final instructorId = await StorageService.getInstructorId();
      
      print('🔑 Token: ${token != null ? "Present (${token.substring(0, 20)}...)" : "Missing"}');
      print('👤 Instructor ID: $instructorId');
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      // Construct the full URL
      final url = '${ApiConstants.baseUrl}${ApiConstants.sectionsEndpoint}';
      print('🌐 Fetching sections from: $url');

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
      print('📝 Full Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> sections = json.decode(response.body);
        
        print('🔍 Total sections received: ${sections.length}');
        
        // Debug: Print first section structure
        if (sections.isNotEmpty) {
          print('📦 Sample section structure: ${json.encode(sections[0])}');
        }
        
        // Group sections by course/program
        final Map<String, List<Map<String, dynamic>>> groupedSections = {};
        
        for (var section in sections) {
          print('-------------------');
          print('Processing section: ${section['id']}');
          print('Full section data: ${json.encode(section)}');
          
          // Filter: Only include sections for this instructor
          if (instructorId != null) {
            final sectionInstructorId = section['instructorId'] ?? 
                                        section['instructor_id'] ?? 
                                        section['InstructorId'];
            
            print('Section instructor ID: $sectionInstructorId vs Current: $instructorId');
            
            if (sectionInstructorId?.toString() != instructorId.toString()) {
              print('⏭️  Skipping section ${section['id']} - Different instructor');
              continue;
            }
          }
          
          // Extract program/course name - try multiple possible paths
          String programName = 'Unknown Program';
          
          // Try different nested structures
          if (section['course'] != null && section['course']['name'] != null) {
            programName = section['course']['name'];
          } else if (section['subject'] != null && section['subject']['course'] != null) {
            programName = section['subject']['course']['name'] ?? section['subject']['course']['Name'] ?? 'Unknown Program';
          } else if (section['Subject'] != null && section['Subject']['Course'] != null) {
            programName = section['Subject']['Course']['Name'] ?? section['Subject']['Course']['name'] ?? 'Unknown Program';
          } else if (section['courseName'] != null) {
            programName = section['courseName'];
          } else if (section['CourseName'] != null) {
            programName = section['CourseName'];
          }
          
          print('📚 Program name extracted: $programName');
          
          // Initialize program list if not exists
          if (!groupedSections.containsKey(programName)) {
            groupedSections[programName] = [];
          }
          
          // Extract subject information - try multiple paths
          String subjectName = 'Unknown Subject';
          String subjectCode = 'N/A';
          
          if (section['subject'] != null) {
            subjectName = section['subject']['name'] ?? section['subject']['Name'] ?? 'Unknown Subject';
            subjectCode = section['subject']['code'] ?? section['subject']['Code'] ?? 'N/A';
          } else if (section['Subject'] != null) {
            subjectName = section['Subject']['Name'] ?? section['Subject']['name'] ?? 'Unknown Subject';
            subjectCode = section['Subject']['Code'] ?? section['Subject']['code'] ?? 'N/A';
          } else if (section['subjectName'] != null) {
            subjectName = section['subjectName'];
            subjectCode = section['subjectCode'] ?? 'N/A';
          }
          
          // Extract section name
          String sectionName = section['name'] ?? 
                              section['Name'] ?? 
                              section['section_name'] ?? 
                              section['sectionName'] ?? 
                              'N/A';
          
          // Extract schedule and room
          String schedule = section['schedule'] ?? 
                           section['Schedule'] ?? 
                           section['timeSlot'] ?? 
                           '';
          
          String room = section['room'] ?? 
                       section['Room'] ?? 
                       section['classroom'] ?? 
                       '';
          
          // Extract student count
          int studentCount = section['student_count'] ?? 
                            section['studentCount'] ?? 
                            section['students_count'] ?? 
                            section['StudentsCount'] ?? 
                            0;
          
          print('✅ Adding section: $subjectCode - $subjectName ($sectionName)');
          
          // Add section to program
          groupedSections[programName]!.add({
            'sectionId': section['id'] ?? section['Id'],
            'name': subjectName,
            'code': subjectCode,
            'section': sectionName,
            'schedule': schedule,
            'room': room,
            'studentCount': studentCount,
          });
        }
        
        print('✅ Grouped sections: ${groupedSections.keys.length} programs');
        groupedSections.forEach((program, sections) {
          print('  📚 $program: ${sections.length} sections');
        });
        
        return {
          'success': true,
          'data': groupedSections,
        };
      } else if (response.statusCode == 401) {
        print('🔒 Unauthorized - Token may be expired');
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
        };
      } else if (response.statusCode == 403) {
        print('🚫 Forbidden - Check backend permissions');
        return {
          'success': false,
          'error': 'Access denied. Your account may not have permission to view sections.',
        };
      } else {
        print('❌ Unexpected status: ${response.statusCode}');
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
  Future<Map<String, dynamic>> getSectionStudents(int sectionId) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Not authenticated. Please login again.',
        };
      }

      final url = '${ApiConstants.baseUrl}${ApiConstants.sectionStudentsEndpoint(sectionId)}';
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
      print('📝 Students Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> students = json.decode(response.body);
        
        final processedStudents = students.map((student) {
          return {
            'id': student['id'] ?? student['Id'],
            'studentId': student['student_id'] ?? student['studentId'] ?? student['StudentId'] ?? student['id_number'] ?? 'N/A',
            'firstName': student['first_name'] ?? student['firstName'] ?? student['FirstName'] ?? student['firstname'] ?? '',
            'lastName': student['last_name'] ?? student['lastName'] ?? student['LastName'] ?? student['lastname'] ?? '',
            'middleName': student['middle_name'] ?? student['middleName'] ?? student['MiddleName'] ?? student['middlename'] ?? '',
            'email': student['email'] ?? student['Email'] ?? '',
            'program': student['course']?['name'] ?? 
                      student['Course']?['Name'] ??
                      student['program']?['name'] ?? 
                      student['Program']?['Name'] ??
                      'N/A',
            'yearLevel': student['year_level']?.toString() ?? 
                        student['yearLevel']?.toString() ??
                        student['YearLevel']?.toString() ??
                        student['year']?.toString() ?? 
                        'N/A',
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

      final url = '${ApiConstants.baseUrl}${ApiConstants.sectionDetailsEndpoint(sectionId)}';
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
            'id': section['id'] ?? section['Id'],
            'name': section['name'] ?? section['Name'] ?? section['section_name'] ?? 'N/A',
            'subjectName': section['subject']?['name'] ?? section['Subject']?['Name'] ?? 'Unknown',
            'subjectCode': section['subject']?['code'] ?? section['Subject']?['Code'] ?? 'N/A',
            'schedule': section['schedule'] ?? section['Schedule'] ?? '',
            'room': section['room'] ?? section['Room'] ?? '',
            'programName': section['subject']?['course']?['name'] ?? 
                          section['Subject']?['Course']?['Name'] ??
                          section['course']?['name'] ?? 
                          section['Course']?['Name'] ??
                          'Unknown',
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