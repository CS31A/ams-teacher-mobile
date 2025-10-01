import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/email_message.dart';
import 'email_modal.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'Student Arrival - 9:00 AM',
      message: 'John Doe has arrived at school',
      time: DateTime.now().subtract(const Duration(minutes: 9)),
      type: NotificationType.arrival,
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'New Email Message',
      message: 'Important: Parent meeting scheduled for tomorrow',
      time: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.email,
      isRead: false,
      emailData: EmailMessage(
        id: 'email_1',
        from: 'principal@school.edu',
        fromName: 'Principal Johnson',
        subject: 'Important: Parent meeting scheduled for tomorrow',
        body: 'Dear Teachers,\n\nI hope this email finds you well. I wanted to remind you about the important parent meeting scheduled for tomorrow at 2:00 PM in the main conference room.\n\nPlease prepare your student progress reports and be ready to discuss any concerns or achievements with the parents.\n\nIf you have any questions, please don\'t hesitate to contact me.\n\nBest regards,\nPrincipal Johnson',
        receivedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        priority: 'High',
        attachments: ['meeting_agenda.pdf', 'student_progress_template.docx'],
      ),
    ),
    NotificationItem(
      id: '3',
      title: 'Student Arrival - 9:00 AM',
      message: 'Jane Smith has arrived at school',
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      type: NotificationType.arrival,
      isRead: false,
    ),
    NotificationItem(
      id: '4',
      title: 'Student Arrival - 9:00 AM',
      message: 'Bob Johnson has arrived at school',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      type: NotificationType.arrival,
      isRead: false,
    ),
    NotificationItem(
      id: '5',
      title: 'New Email Message',
      message: 'Weekly staff newsletter - Updates and announcements',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotificationType.email,
      isRead: true,
      emailData: EmailMessage(
        id: 'email_2',
        from: 'admin@school.edu',
        fromName: 'School Administration',
        subject: 'Weekly staff newsletter - Updates and announcements',
        body: 'Dear Staff,\n\nHere are this week\'s updates and announcements:\n\n1. New parking regulations will be implemented next week\n2. The library will be closed for maintenance on Friday\n3. Please submit your lesson plans by end of week\n4. Upcoming professional development session on Monday\n\nThank you for your attention.\n\nSchool Administration',
        receivedAt: DateTime.now().subtract(const Duration(hours: 1)),
        priority: 'Normal',
      ),
    ),
    NotificationItem(
      id: '6',
      title: 'Late Arrival - 9:15 AM',
      message: 'Alice Brown arrived 15 minutes late',
      time: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.late,
      isRead: true,
    ),
    NotificationItem(
      id: '7',
      title: 'Student Arrival - 9:00 AM',
      message: 'Charlie Wilson has arrived at school',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotificationType.arrival,
      isRead: true,
    ),
    NotificationItem(
      id: '8',
      title: 'Absent Student',
      message: 'David Lee is absent today',
      time: DateTime.now().subtract(const Duration(hours: 4)),
      type: NotificationType.absent,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: _markAllAsRead,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('Mark all read'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: Colors.grey[300],
          ),
        ),
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 40,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return _buildAndroidNotificationCard(notification);
      },
    );
  }

  Widget _buildAndroidNotificationCard(NotificationItem notification) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Icon (Android style)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Time Row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead ? FontWeight.w400 : FontWeight.w500,
                                color: notification.isRead ? Colors.grey[600] : Colors.black87,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(notification.time),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Message
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: notification.isRead ? Colors.grey[500] : Colors.grey[700],
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Unread indicator
                      if (!notification.isRead) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              color: const Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Android-style action button
                if (!notification.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.arrival:
        return Colors.green;
      case NotificationType.late:
        return Colors.orange;
      case NotificationType.absent:
        return Colors.red;
      case NotificationType.email:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.arrival:
        return Icons.login;
      case NotificationType.late:
        return Icons.schedule;
      case NotificationType.absent:
        return Icons.person_off;
      case NotificationType.email:
        return Icons.email;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    });
  }

  void _handleNotificationTap(NotificationItem notification) {
    if (notification.type == NotificationType.email && notification.emailData != null) {
      // Show email modal
      showDialog(
        context: context,
        builder: (context) => EmailModal(email: notification.emailData!),
      );
    }
    
    // Mark as read
    _markAsRead(notification.id);
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  final bool isRead;
  final EmailMessage? emailData;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.isRead,
    this.emailData,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? time,
    NotificationType? type,
    bool? isRead,
    EmailMessage? emailData,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      emailData: emailData ?? this.emailData,
    );
  }
}

enum NotificationType {
  arrival,
  late,
  absent,
  email,
}
