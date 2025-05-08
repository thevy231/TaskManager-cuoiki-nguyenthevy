import 'package:flutter/material.dart';
import '../models/Task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(task.title),
        subtitle: Text("Trạng thái: ${task.status}"),
        leading: CircleAvatar(
          backgroundColor: getPriorityColor(task.priority),
          child: Text("${task.priority}"),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text("Sửa")),
            const PopupMenuItem(value: 'delete', child: Text("Xoá")),
          ],
        ),
      ),
    );
  }
}
