import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasklist/tasks/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> tasks = [];

  Future<void> _addTask() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => const TaskEditScreen()),
    );

    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
        _sortTasks(); // сортируем сразу после добавления
      });
    }
  }

  Future<void> _editTask(int index) async {
    final edited = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskEditScreen(existingTask: tasks[index]),
      ),
    );

    if (edited != null) {
      setState(() {
        tasks[index] = edited;
        _sortTasks();
      });
    }
  }

  /// сортировка по дате (ближайшие первыми)
  void _sortTasks() {
    tasks.sort((a, b) => a.timeUntilConsequences.compareTo(b.timeUntilConsequences));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Мои задачи')),
      body: tasks.isEmpty
          ? const Center(child: Text('Пока нет задач'))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final t = tasks[index];
          final daysLeft = t.timeUntilConsequences.difference(DateTime.now()).inDays;
          final color = daysLeft < 1
              ? Colors.blue[100]
              : (daysLeft < 3 ? Colors.orange[100] : Colors.green[100]);

          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade400, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            color: color,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            child: ListTile(
              title: Text(
                t.name ?? '(Без названия)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${t.value}\nдо ${t.timeUntilConsequences.toLocal().toString().split(" ")[0]}',
                style: const TextStyle(height: 1.4),
              ),
              isThreeLine: true,
              onTap: () => _editTask(index),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TaskEditScreen extends StatefulWidget {
  final Task? existingTask; // null → новая задача

  const TaskEditScreen({super.key, this.existingTask});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _valueController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final task = widget.existingTask;
    _nameController = TextEditingController(text: task?.name ?? '');
    _valueController = TextEditingController(text: task?.value ?? '');
    _selectedDate = task?.timeUntilConsequences ?? DateTime.now().add(Duration(days: 1));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_valueController.text.isEmpty) return;

    final newTask = Task(
      name: _nameController.text.isEmpty ? null : _nameController.text,
      value: _valueController.text,
      timeUntilConsequences: _selectedDate,
    );

    Navigator.pop(context, newTask);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактировать задачу' : 'Новая задача'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTask,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Название задачи',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              decoration: InputDecoration(
                labelText: 'Описание задачи',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Дедлайн: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                ElevatedButton.icon(
                  onPressed: _pickDate,
                  icon: Icon(Icons.calendar_today),
                  label: Text('Выбрать дату'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}