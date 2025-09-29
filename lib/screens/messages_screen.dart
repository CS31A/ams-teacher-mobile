import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/message_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<Message> _messages = [];
  bool _isLoading = false;
  String _selectedFilter = 'all'; // 'all', 'unread', 'read'

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await MessageService.loadMessages();
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load messages: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAsRead(Message message) async {
    if (!message.isRead) {
      await MessageService.markAsRead(message.id);
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = _messages[index].copyWith(isRead: true);
        }
      });
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await MessageService.deleteMessage(message.id);
      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted')),
        );
      }
    }
  }

  Future<void> _exportMessages() async {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No messages to export')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final path = await MessageService.exportMessagesToCSV(_messages);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Messages exported to $path')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  List<Message> get _filteredMessages {
    switch (_selectedFilter) {
      case 'unread':
        return _messages.where((m) => !m.isRead).toList();
      case 'read':
        return _messages.where((m) => m.isRead).toList();
      default:
        return _messages;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportMessages();
              } else if (value == 'refresh') {
                _loadMessages();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'all',
                  onSelected: () => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Unread',
                  isSelected: _selectedFilter == 'unread',
                  onSelected: () => setState(() => _selectedFilter = 'unread'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Read',
                  isSelected: _selectedFilter == 'read',
                  onSelected: () => setState(() => _selectedFilter = 'read'),
                ),
              ],
            ),
          ),
          
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMessages.isEmpty
                    ? const _EmptyState()
                    : ListView.builder(
                        itemCount: _filteredMessages.length,
                        itemBuilder: (context, index) {
                          final message = _filteredMessages[index];
                          return _MessageCard(
                            message: message,
                            onTap: () => _markAsRead(message),
                            onDelete: () => _deleteMessage(message),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
    );
  }
}

class _MessageCard extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MessageCard({
    required this.message,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: message.isRead ? Colors.grey[300] : Colors.blue[100],
          child: Text(
            message.studentName.isNotEmpty ? message.studentName[0] : '?',
            style: TextStyle(
              color: message.isRead ? Colors.grey[600] : Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message.studentName,
                style: TextStyle(
                  fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (!message.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.subject,
              style: TextStyle(
                fontWeight: message.isRead ? FontWeight.normal : FontWeight.w600,
                color: message.isRead ? Colors.grey[600] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (message.tasks.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                '${message.tasks.length} task(s) assigned',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(message.date),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red[700])),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.message_outlined,
              size: 56,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No messages',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Messages sent to absent students will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
