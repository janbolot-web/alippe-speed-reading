import 'package:client/screens/calendar/calendar.dart';
import 'package:client/screens/calendar/widgets/event_card.dart';
import 'package:client/screens/calendar/widgets/titleText.dart';
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
        _buildHeader(context: context),
        Expanded(
          child: _buildTaskList(),
        ),
        _buildAddTaskButton(context),
      ],
    );
  }

  Widget _buildHeader({required BuildContext context}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Менин',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Color(0xffAC046A),
                ),
              ),
              Text(
                'ТАПШЫРМАЛАРЫМ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: section.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                section.title,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              // EditableSectionTitle(
              //   initialTitle: section.title,
              //   onSubmit: (newTitle) {
              //     // Update your section title here
              //     // For example: section.title = newTitle;
              //   },
              // )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return section.tasks.isEmpty
        ? Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Задачи не найдены.\nДобавьте новую задачу!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: section.tasks.length,
            itemBuilder: (context, index) {
              final task = section.tasks[index];

              return EventCard(
                title: task.title,
                date: task.date,
                onCheckChanged: (_) {
                  // Update your task completion status here
                  // For example: task.isCompleted = !task.isCompleted;
                },
                timeRange: task.time,
              );
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

    // Цвета из дизайна
    final Color backgroundColor = const Color(0xFFF5F5F5);
    final Color primaryColor = const Color(0xFF1C313A);
    final Color accentColor = const Color(0xff1B434D);

    // Преобразование даты в формат "МЕСЯЦ \ ДЕНЬ \ ГОД"
    String formatDateCustom(DateTime date) {
      final List<String> monthNames = [
        'ЯНВАРЬ',
        'ФЕВРАЛЬ',
        'МАРТ',
        'АПРЕЛЬ',
        'МАЙ',
        'ИЮНЬ',
        'ИЮЛЬ',
        'АВГУСТ',
        'СЕНТЯБРЬ',
        'ОКТЯБРЬ',
        'НОЯБРЬ',
        'ДЕКАБРЬ'
      ];

      return '${monthNames[date.month - 1]} \\ ${date.day} \\ ${date.year}';
    }

    // Функция для создания временного диапазона
    String formatTimeRange(String startTime, String endTime) {
      if (startTime.isEmpty && endTime.isEmpty) {
        return '00:00 - 00:00';
      }
      return '$startTime - $endTime';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Поле для названия задачи
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Тапшырманы жаз',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[400],
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  Divider(color: Colors.grey[300]),

                  // Поле выбора даты
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Text(
                            formatDateCustom(selectedDate),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(color: Colors.grey[300]),

                  // Поля времени начала и конца
                  InkWell(
                    onTap: () async {
                      // Показать диалог выбора времени
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        final String formattedTime =
                            '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';

                        setState(() {
                          timeController.text = formattedTime;
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Text(
                            timeController.text.isEmpty
                                ? '00:00 - 00:00'
                                : '${timeController.text} - ${(int.parse(timeController.text.split(':')[0]) + 2).toString().padLeft(2, '0')}:${timeController.text.split(':')[1]}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Divider(color: Colors.grey[300]),

                  // Чекбокс для приоритета
                  Row(
                    children: [
                      Checkbox(
                        value: isUrgent,
                        onChanged: (value) {
                          setState(() {
                            isUrgent = value ?? false;
                          });
                        },
                        activeColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Text(
                        'Маанилүү',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Кнопки действий
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Кнопка отмены
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffBA0F43),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Артка',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Кнопка добавления
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final title = titleController.text.trim();
                            String time = timeController.text.trim();

                            // Рассчитываем временной диапазон, если задано только начало
                            if (time.isNotEmpty) {
                              final parts = time.split(':');
                              int hour = int.parse(parts[0]);
                              final endHour = (hour + 2) % 24;
                              time =
                                  '$time - ${endHour.toString().padLeft(2, '0')}:${parts[1]}';
                            } else {
                              time = '00:00 - 00:00';
                            }

                            if (title.isNotEmpty) {
                              onAddTask(title, selectedDate, time, isUrgent);
                              Navigator.pop(context);
                            } else {
                              // Показать сообщение об ошибке
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Пожалуйста, введите название задачи'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Кошуу',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

// Диалог выбора диапазона времени
  Future<Map<String, String>?> showTimeRangePickerDialog(BuildContext context,
      {String? initialStartTime, String? initialEndTime}) async {
    String startTime = initialStartTime ?? '';
    String endTime = initialEndTime ?? '';
    bool confirmed = false;

    final Color accentColor = const Color(0xff1B434D);

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Заголовок
                  Text(
                    'Тандоо убакыт',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Выбор начального времени
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Icon(Icons.access_time, color: Colors.grey[600]),
                      const SizedBox(width: 16),
                      Text(
                        'Башталышы:',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            TimeOfDay initialTime = TimeOfDay.now();
                            if (startTime.isNotEmpty) {
                              final parts = startTime.split(':');
                              initialTime = TimeOfDay(
                                hour: int.parse(parts[0]),
                                minute: int.parse(parts[1]),
                              );
                            }

                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: initialTime,
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: accentColor,
                                    colorScheme: ColorScheme.light(
                                      primary: accentColor,
                                      onSurface: Colors.black,
                                    ),
                                    buttonTheme: ButtonThemeData(
                                      colorScheme: ColorScheme.light(
                                        primary: accentColor,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setState(() {
                                startTime =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              startTime.isEmpty ? '00:00' : startTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[800]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Выбор конечного времени
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Icon(Icons.access_time_filled, color: Colors.grey[600]),
                      const SizedBox(width: 16),
                      Text(
                        'Аягы:       ',
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            TimeOfDay initialTime = TimeOfDay.now();
                            if (endTime.isNotEmpty) {
                              final parts = endTime.split(':');
                              initialTime = TimeOfDay(
                                hour: int.parse(parts[0]),
                                minute: int.parse(parts[1]),
                              );
                            } else if (startTime.isNotEmpty) {
                              // Предлагаем конечное время на 2 часа позже начального
                              final parts = startTime.split(':');
                              int startHour = int.parse(parts[0]);
                              int endHour = (startHour + 2) % 24;
                              initialTime = TimeOfDay(
                                hour: endHour,
                                minute: int.parse(parts[1]),
                              );
                            }

                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: initialTime,
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    primaryColor: accentColor,
                                    colorScheme: ColorScheme.light(
                                      primary: accentColor,
                                      onSurface: Colors.black,
                                    ),
                                    buttonTheme: ButtonThemeData(
                                      colorScheme: ColorScheme.light(
                                        primary: accentColor,
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setState(() {
                                endTime =
                                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[400]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              endTime.isEmpty ? '00:00' : endTime,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[800]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Кнопки
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                        ),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          confirmed = true;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: const Text(
                          'Тандоо',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (confirmed) {
      return {
        'startTime': startTime.isEmpty ? '00:00' : startTime,
        'endTime': endTime.isEmpty ? '00:00' : endTime,
      };
    }

    return null;
  }

// Стильный календарь для выбора даты
  Future<DateTime?> showStyledDatePicker(BuildContext context,
      {required DateTime initialDate}) async {
    final primaryColor = const Color(0xff1B434D);
    final accentColor = const Color(0xffBA0F43);

    // Список месяцев на кириллице

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
              secondary: accentColor,
              onSecondary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: primaryColor,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              dayStyle: const TextStyle(fontSize: 16),
              weekdayStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
              todayBackgroundColor:
                  MaterialStateProperty.all(primaryColor.withOpacity(0.15)),
              todayForegroundColor: MaterialStateProperty.all(primaryColor),
              // selectedBackgroundColor: MaterialStateProperty.all(primaryColor),
              // selectedForegroundColor: MaterialStateProperty.all(Colors.white),
              backgroundColor: Colors.white,
              yearStyle: const TextStyle(fontSize: 16),
              surfaceTintColor: Colors.white,
              dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return primaryColor;
                }
                return null;
              }),
              dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return null;
              }),
              rangePickerBackgroundColor: Colors.white,
              rangePickerSurfaceTintColor: Colors.white,
              rangeSelectionBackgroundColor: primaryColor.withOpacity(0.15),
              rangeSelectionOverlayColor:
                  MaterialStateProperty.all(primaryColor.withOpacity(0.15)),
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: const Locale('ru', 'RU'),
            child: child!,
          ),
        );
      },
    );
  }

// Преобразование даты в формат "МЕСЯЦ \ ДЕНЬ \ ГОД"
  String formatDateCustom(DateTime date) {
    final List<String> monthNames = [
      'ЯНВАРЬ',
      'ФЕВРАЛЬ',
      'МАРТ',
      'АПРЕЛЬ',
      'МАЙ',
      'ИЮНЬ',
      'ИЮЛЬ',
      'АВГУСТ',
      'СЕНТЯБРЬ',
      'ОКТЯБРЬ',
      'НОЯБРЬ',
      'ДЕКАБРЬ'
    ];

    return '${monthNames[date.month - 1]} \\ ${date.day} \\ ${date.year}';
  }
}
