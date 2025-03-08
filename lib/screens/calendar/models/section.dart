import 'package:flutter/material.dart';
import 'task.dart';

class Section {
  final String id;
  final String title;
  final String letter;
  final Color color;
  final List<Task> tasks;

  Section({
    required this.id,
    required this.title,
    required this.letter,
    required this.color,
    List<Task>? tasks,
  }) : tasks = tasks ?? [];
}