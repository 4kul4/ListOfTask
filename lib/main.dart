import 'package:flutter/material.dart';
import 'package:tasklist/tasks/task.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screen/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  runApp(const MyTaskList());
}

class MyTaskList extends StatelessWidget {
  const MyTaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список задач',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TaskTabsScreen(),
      debugShowCheckedModeBanner: false
    );
  }
}