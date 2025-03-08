// Универсальная страница раздела с задачами
import 'package:client/screens/calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SectionPage extends StatelessWidget {
  final Section section;
  final Function(String, DateTime, String, bool) onAddTask;

  const SectionPage({
    super.key,
    required this.section,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: _buildTaskList(),
        ),
        _buildAddTaskButton(context),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ТАПШЫРМАЛАРЫМ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: section.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return section.tasks.isEmpty
        ? Center(
            child: Text(
              'Задачи не найдены.\nДобавьте новую задачу!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: section.tasks.length,
            itemBuilder: (context, index) {
              final task = section.tasks[index];
              return _buildTaskItem(task);
            },
          );
  }

// Для задач с чекбоксом предлагаю переработать строку так, чтобы она не ломалась
// (альтернативный подход для задач)
  Widget _buildTaskItem(item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                item.time,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Checkbox(
              value: false,
              onChanged: (_) {},
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.red,
                size: 16,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () => _showAddTaskDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C313A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Жаңы тапшырма кошуу',
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

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Новая задача в разделе "${section.title}"'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Название задачи
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Название задачи',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Выбор даты
                  const Text(
                    'Дата:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2026),
                      );

                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('dd.MM.yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Время
                  TextField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: 'Время (HH:MM)',
                      border: OutlineInputBorder(),
                      hintText: 'Например: 14:30',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Флаг срочности
                  Row(
                    children: [
                      Checkbox(
                        value: isUrgent,
                        onChanged: (value) {
                          setState(() {
                            isUrgent = value ?? false;
                          });
                        },
                      ),
                      const Text('Срочная задача'),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  final time = timeController.text.trim();

                  if (title.isNotEmpty && _validateTime(time)) {
                    onAddTask(title, selectedDate, time, isUrgent);
                    Navigator.pop(context);
                  } else {
                    // Показать сообщение об ошибке
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Пожалуйста, заполните все поля корректно'),
                      ),
                    );
                  }
                },
                child: const Text('Добавить'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Метод для валидации времени
  bool _validateTime(String time) {
    // Проверяем формат времени (HH:MM)
    final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):([0-5][0-9])$');
    return regex.hasMatch(time);
  }
}
