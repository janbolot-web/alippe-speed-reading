import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EventCard extends StatefulWidget {
  final String title;
  final date;
  final String
      timeRange; // Диапазон времени как единый параметр (например "10:00 - 12:00")
  final bool isCompleted;
  final Function(bool?) onCheckChanged;

  const EventCard({
    Key? key,
    required this.title,
    required this.date,
    required this.timeRange,
    this.isCompleted = false,
    required this.onCheckChanged,
  }) : super(key: key);

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  late bool _isChecked;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    // Разделение строки времени на начало и конец для отображения
    List<String> timeParts = widget.timeRange.split(' - ');
    String startTime = timeParts.length > 0 ? timeParts[0] : "";
    String endTime = timeParts.length > 1 ? timeParts[1] : "";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: Color(0xff1B434D), width: 1.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox with custom appearance
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.0),
                    border: Border.all(
                      color: const Color(0xffA22766),
                      width: 1.5,
                    ),
                  ),
                  child: Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                      widget.onCheckChanged(value);
                    },
                    fillColor: MaterialStateProperty.all(Colors.transparent),
                    checkColor: const Color(0xffA22766),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    side: BorderSide.none,
                  ),
                ),
                const SizedBox(width: 16),
                // Title text
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2D4356),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            // Date and time row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date
                Text(
                  formatDateCustom(widget.date),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    color: Color(0xff7D8A8D),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                // Time range separated for display
                Row(
                  children: [
                    Text(
                      startTime,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        color: Color(0xff7D8A8D),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Text(
                      " - ",
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      endTime,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                // Completed label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffBA0F43),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Text(
                    'зарыл',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Пример использования
class EventCardExample extends StatelessWidget {
  const EventCardExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: Center(
        child: EventCard(
          title: 'Апамдарды коноко чакырып, туулган күн өткөзүү',
          date: 'МАРТ \\ 1 \\ 2025',
          timeRange: '10:00 - 12:00',
          onCheckChanged: (value) {
            print('Checkbox changed: $value');
          },
        ),
      ),
    );
  }
}

// Функция для создания диапазона времени из DateTime объектов
String createTimeRangeFromDateTime(DateTime start, DateTime end) {
  String formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  return '${formatTime(start)} - ${formatTime(end)}';
}

// Пример использования с DateTime объектами
EventCard createEventCardWithDateTime() {
  final DateTime startDateTime = DateTime(2025, 3, 1, 10, 0);
  final DateTime endDateTime = DateTime(2025, 3, 1, 12, 0);

  return EventCard(
    title: 'Апамдарды коноко чакырып, туулган күн өткөзүү',
    date: formatDateCustom(startDateTime),
    timeRange: createTimeRangeFromDateTime(startDateTime, endDateTime),
    onCheckChanged: (value) {},
  );
}

// Функция форматирования даты
String formatDateCustom(DateTime date) {
  final List<String> monthNames = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь'
  ];

  String month = monthNames[date.month - 1].toUpperCase();
  return '$month \\ ${date.day} \\ ${date.year}';
}
