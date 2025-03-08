import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Класс для хранения информации о разделе
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

// Расширенный класс для хранения задачи
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

  // Метод для получения DateTime из строки времени
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

// Класс для хранения предмета/расписания
class ScheduleItem {
  final String id;
  final String time;
  final String subject;
  final String classInfo;
  final DateTime date;
  final bool
      isTask; // Определяет, является ли это задачей или предметом в расписании

  ScheduleItem({
    required this.id,
    required this.time,
    required this.subject,
    required this.classInfo,
    required this.date,
    this.isTask = false,
  });

  // Метод для получения DateTime из строки времени
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

  // Статический метод для сортировки по времени
  static List<ScheduleItem> sortByTime(List<ScheduleItem> items) {
    items.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
    return items;
  }

  // Конвертация задачи в элемент расписания
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


// Страница добавления раздела
class AddSectionPage extends StatefulWidget {
  final Function(String, String, Color) onSectionAdded;

  const AddSectionPage({
    super.key,
    required this.onSectionAdded,
  });

  @override
  State<AddSectionPage> createState() => _AddSectionPageState();
}

class _AddSectionPageState extends State<AddSectionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _letterController = TextEditingController();
  Color _selectedColor = Colors.blue;

  @override
  void dispose() {
    _titleController.dispose();
    _letterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Поле для названия раздела
                const Text(
                  'Название раздела',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Например: Проекты, Хобби, Спорт...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Поле для буквы (иконки) раздела
                const Text(
                  'Буква для иконки',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _letterController,
                  decoration: const InputDecoration(
                    hintText: 'Одна буква',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Выбор цвета раздела
                const Text(
                  'Цвет раздела',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildColorPicker(),
                const SizedBox(height: 32),

                // Предпросмотр иконки раздела
                const Text(
                  'Предпросмотр',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ],
                      border: Border.all(color: _selectedColor, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        _letterController.text.isEmpty
                            ? '?'
                            : _letterController.text,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _selectedColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildAddSectionButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Добавление нового раздела',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C313A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildColorOption(Colors.red),
        _buildColorOption(Colors.orange),
        _buildColorOption(Colors.amber),
        _buildColorOption(Colors.green),
        _buildColorOption(Colors.teal),
        _buildColorOption(Colors.blue),
        _buildColorOption(Colors.indigo),
        _buildColorOption(Colors.purple),
        _buildColorOption(Colors.pink),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor.value == color.value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              )
            : null,
      ),
    );
  }

  Widget _buildAddSectionButton() {
    final bool isFormValid = _titleController.text.trim().isNotEmpty &&
        _letterController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: isFormValid ? _addSection : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C313A),
            disabledBackgroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Добавить раздел',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _addSection() {
    final String title = _titleController.text.trim();
    final String letter = _letterController.text.trim();

    if (title.isNotEmpty && letter.isNotEmpty) {
      widget.onSectionAdded(title, letter, _selectedColor);
    }
  }
}

