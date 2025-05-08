import 'package:flutter/material.dart';
import '../models/Task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chi tiết công việc")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Tiêu đề: ${task.title}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("Mô tả: ${task.description}"),
            const SizedBox(height: 8),
            Text("Trạng thái: ${task.status}"),
            Text("Độ ưu tiên: ${task.priority}"),
            Text("Hạn: ${task.dueDate?.toString().split(' ')[0] ?? 'Không có'}"),
            Text("Tạo bởi: ${task.createdBy}"),
            Text("Hoàn thành: ${task.completed ? 'Có' : 'Chưa'}"),
          ],
        ),
      ),
    );
  }
}
