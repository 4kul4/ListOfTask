import 'package:hive/hive.dart';

part 'task.g.dart'; // генерируется автоматически

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String? name;

  @HiveField(1)
  String value;

  @HiveField(2)
  DateTime timeUntilConsequences;

  @HiveField(3)
  bool isCompleted;

  Task({
    this.name,
    required this.value,
    required this.timeUntilConsequences,
    this.isCompleted = false,
  });

  // Копирования объекта с изменением некоторых полей
  Task copyWith({
    String? name,
    String? value,
    DateTime? timeUntilConsequences,
  }) {
    return Task(
      name: name ?? this.name,
      value: value ?? this.value,
      timeUntilConsequences: timeUntilConsequences ?? this.timeUntilConsequences,
    );
  }

  // Хранение в базе
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'value': value,
      'timeUntilConsequences': timeUntilConsequences.toIso8601String(),
    };
  }

  // Создание Task из Map при чтении из базы
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      value: map['value'],
      timeUntilConsequences: DateTime.parse(map['timeUntilConsequences']),
    );
  }

  // Вывод для отладки
  @override
  String toString() {
    return 'Task(name: $name, value: $value, time: $timeUntilConsequences)';
  }
}
