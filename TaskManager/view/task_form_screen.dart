import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/User.dart';
import '../models/Task.dart';
import '../db/DatabaseHelper.dart';

class TaskFormScreen extends StatefulWidget {
  final User currentUser;
  final Task? existingTask;

  const TaskFormScreen({super.key, required this.currentUser, this.existingTask});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseHelper.instance;
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _status = 'To do';
  int _priority = 1;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    if (widget.existingTask != null) {
      final t = widget.existingTask!;
      _titleController.text = t.title;
      _descController.text = t.description;
      _status = t.status;
      _priority = t.priority;
      _dueDate = t.dueDate;
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final task = Task(
        id: widget.existingTask?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descController.text,
        status: _status,
        priority: _priority,
        dueDate: _dueDate,
        createdAt: widget.existingTask?.createdAt ?? now,
        updatedAt: now,
        assignedTo: null,
        createdBy: widget.currentUser.id,
        category: null,
        attachments: [],
        completed: _status == 'Done',
      );

      if (widget.existingTask == null) {
        await _db.insertTask(task);
      } else {
        await _db.updateTask(task);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingTask == null ? "Thêm công việc" : "Sửa công việc")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Tiêu đề"),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Mô tả"),
              ),
              DropdownButtonFormField(
                value: _status,
                decoration: const InputDecoration(labelText: "Trạng thái"),
                items: ['To do', 'In progress', 'Done', 'Cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(labelText: "Độ ưu tiên"),
                items: [1, 2, 3]
                    .map((p) => DropdownMenuItem(value: p, child: Text("Mức $p")))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value!),
              ),
              ListTile(
                title: Text(_dueDate != null
                    ? "Hạn: ${_dueDate!.toLocal().toString().split(' ')[0]}"
                    : "Chọn hạn hoàn thành"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text("Lưu")),
            ],
          ),
        ),
      ),
    );
  }
}
