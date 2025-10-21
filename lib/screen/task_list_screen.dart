import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasklist/screen/task_edit_screen.dart';
import 'package:tasklist/tasks/task.dart';

class TaskTabsScreen extends StatefulWidget {
  const TaskTabsScreen({super.key});

  @override
  State<TaskTabsScreen> createState() => _TaskTabsScreenState();
}

class _TaskTabsScreenState extends State<TaskTabsScreen> {
  late Box<Task> taskBox;

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box<Task>('tasks');
  }

  void _addTask() async {
    final newTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const TaskEditScreen()),
    );

    if (newTask != null) {
      taskBox.add(newTask);
      setState(() {});
    }
  }

  void _toggleTask(Task task) {
    task.isCompleted = !task.isCompleted;
    task.save();
    setState(() {});
  }

  void _editTask(Task task) async {
    final edited = await Navigator.push<Task>(
      context,
      MaterialPageRoute(
        builder: (_) => TaskEditScreen(existingTask: task),
      ),
    );

    if (edited != null) {
      task.name = edited.name;
      task.value = edited.value;
      task.timeUntilConsequences = edited.timeUntilConsequences;
      task.save();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = taskBox.values.toList();
    tasks.sort((a, b) =>
        a.timeUntilConsequences.compareTo(b.timeUntilConsequences));

    final activeTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Список на выполнение'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'В процессе'),
              Tab(text: 'Выполненные'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(activeTasks),
            _buildTaskList(completedTasks),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTask,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('Нет задач'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final t = tasks[index];
        final daysLeft = t.timeUntilConsequences
            .difference(DateTime.now())
            .inDays;
        final color = t.isCompleted
            ? Colors.grey[400]
            : (daysLeft < 1
            ? Colors.red[100]
            : daysLeft < 3
            ? Colors.green[50]
            : Colors.indigoAccent[100]);

        return Dismissible(
          key: Key(t.key.toString()),
          // уникальный ключ из Hive
          direction: DismissDirection.endToStart,
          // свайп влево
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.redAccent,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog(
              context: context,
              builder: (context) =>
                  AlertDialog(
                    title: const Text('Удалить задачу?'),
                    content: const Text('Это действие нельзя отменить.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                            'Удалить', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (_) {
            t.delete(); // удаляем из Hive
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Задача "${t.name ?? ''}" удалена')),
            );
            setState(() {});
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade400),
            ),
            elevation: 0,
            color: color,
            child: ListTile(
              leading: Checkbox(
                value: t.isCompleted,
                onChanged: (_) {
                  t.isCompleted = !t.isCompleted;
                  t.save();
                  setState(() {});
                },
              ),
              title: Text(
                t.name ?? '(Без названия)',
                style: TextStyle(
                  decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${t.value}\nдо ${t.timeUntilConsequences
                    .toLocal()
                    .toString()
                    .split(" ")[0]}',
                style: const TextStyle(height: 1.4),
              ),
              isThreeLine: true,
              onTap: () => _editTask(t),
            ),
          ),
        );
      },
    );
  }
}