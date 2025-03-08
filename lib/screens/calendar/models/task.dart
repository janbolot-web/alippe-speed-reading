import 'package:flutter/material.dart';

class Task {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final bool isUrgent;
  final String sectionId;
  final String sectionTitle;
  final Color sectionColor;

  Task({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.isUrgent,
    required this.sectionId,
    required this.sectionTitle,
    required this.sectionColor,
  });

  DateTime getDateTime() {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    
    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }
}