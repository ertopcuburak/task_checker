import 'package:flutter/material.dart';
import 'task_details_screen.dart';

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
  final List<Task> _tasks = [];

  void _addTask(String title, String description) {
    setState(() {
      _tasks.add(Task(title: title, description: description));
    });
  }

  void _editTask(int index, String title, String description) {
    setState(() {
      _tasks[index].title = title;
      _tasks[index].description = description;
    });
  }

  void _toggleTaskDone(int index) {
    setState(() {
      _tasks[index].isDone = !_tasks[index].isDone;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showTaskDetails(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task),
      ),
    );
  }

  void _showTaskForm({Task? task, int? index}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descriptionController = TextEditingController(text: task?.description ?? '');

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
              onPressed: () {
                if (task == null) {
                  _addTask(titleController.text, descriptionController.text);
                } else if (index != null) {
                  _editTask(index, titleController.text, descriptionController.text);
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
      body: ListView.builder(
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
            subtitle: task.description.isNotEmpty ? Text(task.description) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showTaskForm(task: task, index: index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteTask(index),
                ),
              ],
            ),
            onTap: () => _showTaskDetails(task),
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
