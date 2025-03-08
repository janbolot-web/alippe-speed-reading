import 'task.dart';

class ScheduleItem {
  final String id;
  final String time;
  final String subject;
  final String classInfo;
  final DateTime date;
  final bool isTask;

  ScheduleItem({
    required this.id,
    required this.time,
    required this.subject,
    required this.classInfo,
    required this.date,
    this.isTask = false,
  });

  DateTime getDateTime() {
    final parts = time.split(' - ')[0].split(':');
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

  static List<ScheduleItem> sortByTime(List<ScheduleItem> items) {
    items.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
    return items;
  }

  static ScheduleItem fromTask(Task task) {
    return ScheduleItem(
      id: task.id,
      time: task.time,
      subject: task.title,
      classInfo: task.sectionTitle,
      date: task.date,
      isTask: true,
    );
  }
}