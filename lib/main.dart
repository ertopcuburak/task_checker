import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_details_screen.dart'; // Import TaskDetailsScreen

void main() {
  runApp(TaskCheckerApp());
}

class TaskCheckerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Checker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListScreen(),
    );
  }
}

class Task {
  String title;
  String description;
  bool isDone;

  Task({required this.title, this.description = '', this.isDone = false});
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = [];
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    setState(() {
      _tasks = keys
          .where((key) => key.trim().isNotEmpty)
          .map((key) => Task(
        title: key,
        description: prefs.getString(key) ?? "",
      ))
          .toList();
    });
  }

  Future<void> _addTask(String title, String description) async {
    final newTask = Task(title: title, description: description);
    setState(() {
      _tasks.add(newTask);
    });
    await storeData(title, description);
  }

  Future<void> _editTask(int index, String title, String description) async {
    final oldTitle = _tasks[index].title;
    setState(() {
      _tasks[index].title = title;
      _tasks[index].description = description;
    });
    await clearDataByKey(oldTitle);
    await storeData(title, description);
  }

  void _toggleTaskDone(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
    // You may want to store the updated task status here if needed
  }

  Future<void> _deleteTask(int index) async {
    final key = _tasks[index].title;
    setState(() {
      _tasks.removeAt(index);
    });
    await clearDataByKey(key);
  }

  void _showTaskDetails(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task),
      ),
    );
  }

  Future<void> storeData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> clearDataByKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  void _showTaskForm({Task? task, int? index}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController =
    TextEditingController(text: task?.description ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'New Task' : 'Edit Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (task == null) {
                  await _addTask(
                      titleController.text, descriptionController.text);
                } else if (index != null) {
                  await _editTask(index, titleController.text,
                      descriptionController.text);
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Checker'),
      ),
      body: _tasks.isEmpty
          ? Center(child: Text('No tasks found'))
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task.isDone,
              onChanged: (value) {
                _toggleTaskDone(index);
              },
            ),
            title: Text(task.title),
            subtitle: task.description.isNotEmpty
                ? Text(task.description)
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () =>
                      _showTaskForm(task: task, index: index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTask(index),
                ),
              ],
            ),
            onTap: () => _showTaskDetails(task), // Navigate to TaskDetailsScreen
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
