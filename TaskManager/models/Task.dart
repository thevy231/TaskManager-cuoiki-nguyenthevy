class Task {
  final String id;
  final String title;
  final String description;
  final String status;
  final int priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? assignedTo;
  final String createdBy;
  final String? category;
  final List<String>? attachments;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    required this.createdBy,
    this.category,
    this.attachments,
    required this.completed,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'dueDate': dueDate?.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'assignedTo': assignedTo,
    'createdBy': createdBy,
    'category': category,
    'attachments': attachments?.join(','),
    'completed': completed ? 1 : 0,
  };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'],
    title: map['title'],
    description: map['description'],
    status: map['status'],
    priority: map['priority'],
    dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
    createdAt: DateTime.parse(map['createdAt']),
    updatedAt: DateTime.parse(map['updatedAt']),
    assignedTo: map['assignedTo'],
    createdBy: map['createdBy'],
    category: map['category'],
    attachments: map['attachments']?.split(','),
    completed: map['completed'] == 1,
  );
}
