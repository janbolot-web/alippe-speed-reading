// Страница календаря и регламента
import 'package:client/screens/calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final Function(String, String, String, DateTime) onAddScheduleItem;
  final Function(DateTime) getScheduleItemsForDate;
  final List<ScheduleItem> scheduleItems;
  final Map<DateTime, List<String>> holidays;

  const CalendarPage({
    super.key,
    required this.onAddScheduleItem,
    required this.getScheduleItemsForDate,
    required this.scheduleItems,
    required this.holidays,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime(2025, 2, 20);
  DateTime _selectedDay = DateTime(2025, 2, 20);
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final List<String> weekdaysShort = [
    'дүй',
    'шей',
    'шар',
    'бей',
    'жум',
    'шар',
    'жек'
  ];

  final Map<int, String> dayNamesKyrgyz = {
    1: 'Дүйшөмбү',
    2: 'Шейшемби',
    3: 'Шаршемби',
    4: 'Бейшемби',
    5: 'Жума',
    6: 'Ишемби',
    7: 'Жекшемби',
  };

  // Текущие элементы расписания для выбранной даты
  List<ScheduleItem> _currentItems = [];

  @override
  void initState() {
    super.initState();
    _updateCurrentItems();
  }

  // Обновляем список текущих элементов при изменении даты
  void _updateCurrentItems() {
    setState(() {
      _currentItems = widget.getScheduleItemsForDate(_selectedDay);
    });
  }

  // Добавляем новый элемент расписания
  void _addItem(String time, String subject, String classInfo) {
    widget.onAddScheduleItem(time, subject, classInfo, _selectedDay);
    _updateCurrentItems();
  }

  // Удаляем элемент из расписания
  void _removeItem(String id) {
    setState(() {
      _currentItems.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarHeader(),
          _buildTableCalendar(),
          _buildRegulationHeader(),
          _buildDayNavigation(),
          _buildScheduleItems(),
          _buildAddButton(),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 64, 24, 16),
      child: Text(
        '2025 Февраль',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1C313A),
        ),
      ),
    );
  }

  Widget _buildTableCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF78909C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        firstDay: DateTime(2024),
        lastDay: DateTime(2026),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Month',
        },
        holidayPredicate: (day) {
          // Проверяем, является ли день праздничным
          return widget.holidays.keys.any((holiday) => isSameDay(holiday, day));
        },
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: const TextStyle(color: Colors.white),
          weekendStyle: const TextStyle(color: Colors.white),
          dowTextFormatter: (date, locale) {
            return weekdaysShort[date.weekday - 1];
          },
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronVisible: false,
          rightChevronVisible: false,
          titleTextStyle: TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
          headerMargin: EdgeInsets.only(bottom: 8),
          headerPadding: EdgeInsets.all(0),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: const TextStyle(color: Colors.white),
          weekendTextStyle: const TextStyle(color: Colors.white),
          outsideTextStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          todayDecoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.2),
          ),
          todayTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          selectedDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.transparent,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          holidayTextStyle: const TextStyle(
            color: Color(0xFFFF9800),
            fontWeight: FontWeight.bold,
          ),
          markersMaxCount: 0,
        ),
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
            _updateCurrentItems();
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            // Проверяем, является ли день праздничным
            final isHoliday =
                widget.holidays.keys.any((holiday) => isSameDay(holiday, day));

            if (isHoliday) {
              return Center(
                child: Text(
                  day.day.toString(),
                  style: const TextStyle(
                    color: Color(0xFFFF9800),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }

            // Если это день 20
            if (day.day == 20 && day.month == 2 && day.year == 2025) {
              return Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      "20",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }
            return null;
          },
          // Выделяем текущий день жирным
          todayBuilder: (context, day, focusedDay) {
            return Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegulationHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Менин',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            'РЕГЛАМЕНТИМ',
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

  Widget _buildDayNavigation() {
    String displayedDayName =
        dayNamesKyrgyz[_selectedDay.weekday] ?? 'Бейшемби';

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 16, color: Color(0xFF1C313A)),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                _focusedDay = _selectedDay;
                _updateCurrentItems();
              });
            },
          ),
          Text(
            displayedDayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C313A),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                size: 16, color: Color(0xFF1C313A)),
            onPressed: () {
              setState(() {
                _selectedDay = _selectedDay.add(const Duration(days: 1));
                _focusedDay = _selectedDay;
                _updateCurrentItems();
              });
            },
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                size: 22, color: Color(0xFF1C313A)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItems() {
    if (_currentItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_busy,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'На ${DateFormat('dd.MM.yyyy').format(_selectedDay)} нет занятий',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _currentItems.map((item) => _buildScheduleItem(item)).toList(),
    );
  }

  Widget _buildScheduleItem(ScheduleItem item) {
    // Для обычных уроков - желтый цвет, для задач - белый
    final Color containerColor =
        item.isTask ? Colors.white : const Color(0xFFFFC107);
    final bool isNotTask = !item.isTask;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 6), // Уменьшил отступы по бокам
      child: Row(
        children: [
          // Первый контейнер с временем
          Container(
            width: 100, // Уменьшил ширину
            height: 48,
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                item.time,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Средний контейнер с текстом
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: !isNotTask
                  ? Row(
                      children: [
                        const SizedBox(width: 8),
                        Checkbox(
                          value: false,
                          onChanged: (_) {},
                          materialTapTargetSize: MaterialTapTargetSize
                              .shrinkWrap, // Уменьшаем размер
                          visualDensity:
                              VisualDensity.compact, // Делаем более компактным
                        ),
                        Expanded(
                          child: Text(
                            item.subject,
                            style: const TextStyle(
                              fontSize: 14, // Уменьшенный размер шрифта
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          item.subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 8),

          // Последний контейнер для класса (только для предметов)
          if (isNotTask)
            Container(
              width: 55, // Уменьшил ширину
              height: 48,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  item.classInfo,
                  style: const TextStyle(
                    fontSize: 14, // Уменьшенный размер шрифта
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Кнопка удаления, более компактная
          SizedBox(
            width: 24, // Фиксированная ширина
            height: 24, // Фиксированная высота
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.red,
                size: 16, // Уменьшенный размер иконки
              ),
              onPressed: () => _removeItem(item.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

// Обновленный метод _buildAddButton с более компактной кнопкой
  Widget _buildAddButton() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8), // Уменьшенные отступы
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Кошуу',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C313A),
            ),
          ),
          SizedBox(width: 4),
          Icon(
            Icons.add,
            color: Color(0xFF1C313A),
          ),
        ],
      ),
    );
  }

  // Показываем диалог для добавления нового элемента в расписание
  void _showAddScheduleItemDialog(BuildContext context) {
    final TextEditingController timeStartController = TextEditingController();
    final TextEditingController timeEndController = TextEditingController();
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController classInfoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить предмет в расписание'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Дата:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd.MM.yyyy').format(_selectedDay),
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Время начала
              TextField(
                controller: timeStartController,
                decoration: const InputDecoration(
                  labelText: 'Время начала (HH:MM)',
                  border: OutlineInputBorder(),
                  hintText: 'Например: 08:00',
                ),
              ),
              const SizedBox(height: 16),

              // Время окончания
              TextField(
                controller: timeEndController,
                decoration: const InputDecoration(
                  labelText: 'Время окончания (HH:MM)',
                  border: OutlineInputBorder(),
                  hintText: 'Например: 08:45',
                ),
              ),
              const SizedBox(height: 16),

              // Название предмета
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: 'Название предмета',
                  border: OutlineInputBorder(),
                  hintText: 'Например: Алгебра',
                ),
              ),
              const SizedBox(height: 16),

              // Класс
              TextField(
                controller: classInfoController,
                decoration: const InputDecoration(
                  labelText: 'Класс',
                  border: OutlineInputBorder(),
                  hintText: 'Например: 9-кл',
                ),
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
              final timeStart = timeStartController.text.trim();
              final timeEnd = timeEndController.text.trim();
              final subject = subjectController.text.trim();
              final classInfo = classInfoController.text.trim();

              if (timeStart.isNotEmpty &&
                  timeEnd.isNotEmpty &&
                  subject.isNotEmpty &&
                  classInfo.isNotEmpty) {
                _addItem(
                  '$timeStart - $timeEnd',
                  subject,
                  classInfo,
                );
                Navigator.pop(context);
              } else {
                // Показать сообщение об ошибке
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Пожалуйста, заполните все поля'),
                  ),
                );
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

// Обновленный метод _buildSaveButton с меньшими отступами
  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Уменьшенные отступы
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Расписание сохранено'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C313A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Сактоо',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
