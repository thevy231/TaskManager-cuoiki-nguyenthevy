import 'package:flutter/material.dart';
import '../models/Task.dart';
import '../models/User.dart';
import '../db/DatabaseHelper.dart';
import '../view/task_form_screen.dart';
import '../view/task_detail_screen.dart';
import '../widgets/task_item.dart';

class TaskListScreen extends StatefulWidget {
  final User currentUser;

  const TaskListScreen({super.key, required this.currentUser});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final db = DatabaseHelper.instance;
  List<Task> tasks = [];
  String searchQuery = "";
  String? filterStatus;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    List<Task> result;
    if (searchQuery.isNotEmpty) {
      result = await db.searchTasks(searchQuery);
    } else if (filterStatus != null) {
      result = await db.filterTasks(status: filterStatus);
    } else {
      result = await db.getAllTasks();
    }

    setState(() => tasks = result.where((t) => t.createdBy == widget.currentUser.id).toList());
  }

  void _goToForm([Task? task]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(
          currentUser: widget.currentUser,
          existingTask: task,
        ),
      ),
    );
    _loadTasks();
  }

  void _deleteTask(Task task) async {
    await db.deleteTask(task.id);
    _loadTasks();
  }

  void _onSearchChanged(String value) {
    searchQuery = value;
    _loadTasks();
  }

  void _onFilterChanged(String? value) {
    setState(() {
      filterStatus = value;
      _loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Danh sách công việc"),
        actions: [
          DropdownButton<String>(
            value: filterStatus,
            hint: const Text("Lọc", style: TextStyle(color: Colors.white)),
            dropdownColor: Colors.blue,
            underline: Container(),
            onChanged: _onFilterChanged,
            items: [
              'To do',
              'In progress',
              'Done',
              'Cancelled',
              null,
            ].map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status ?? "Tất cả"),
              );
            }).toList(),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Tìm kiếm công việc",
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, index) => TaskItem(
                task: tasks[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TaskDetailScreen(task: tasks[index]),
                  ),
                ).then((_) => _loadTasks()),
                onDelete: () => _deleteTask(tasks[index]),
                onEdit: () => _goToForm(tasks[index]),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _goToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
