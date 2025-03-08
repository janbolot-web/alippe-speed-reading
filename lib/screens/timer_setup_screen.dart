// Полный код класса TimerSetupScreen с правильной обработкой параметров:
import 'package:client/screens/reading_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimerSetupScreen extends StatefulWidget {
  final String title;
  final String content;
  final List<Map<String, dynamic>> questions;
  final String classLevel;
  final String wordsCount;

  const TimerSetupScreen({
    super.key,
    required this.title,
    required this.content,
    required this.questions,
    required this.classLevel,
    required this.wordsCount,
  });

  @override
  _TimerSetupScreenState createState() => _TimerSetupScreenState();
}

class _TimerSetupScreenState extends State<TimerSetupScreen> {
  bool _timerEnabled = true;
  String _selectedDuration = '1 мүнөт';
  final TextEditingController _customDurationController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _customDurationController.text = '1'; // Значение по умолчанию
  }

  @override
  void dispose() {
    _customDurationController.dispose();
    super.dispose();
  }

  // Получить продолжительность в секундах
  int _getDurationInSeconds() {
    if (_selectedDuration == '30 секунд') {
      return 30;
    } else if (_selectedDuration == '1 мүнөт') {
      return 60;
    } else if (_selectedDuration == '__ мүнөт') {
      // Получаем пользовательское время
      final value = int.tryParse(_customDurationController.text);
      if (value != null && value > 0) {
        return value * 60; // Конвертировать минуты в секунды
      }
      return 60; // По умолчанию 1 минута
    }
    return 60; // По умолчанию 1 минута
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B383A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B383A),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о тексте
            Row(
              children: [
                _buildInfoItem('${widget.classLevel}-класс'),
                const SizedBox(width: 10),
                _buildInfoItem('${widget.wordsCount} сөз'),
                const SizedBox(width: 10),
                _buildInfoItem('${widget.questions.length} суроо'),
              ],
            ),

            const SizedBox(height: 30),

            // Переключатель таймера
            Row(
              children: [
                Text(
                  'Окуучуну убакытка ченөө',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1B383A),
                  ),
                ),
                const Spacer(),
                Switch(
                  value: _timerEnabled,
                  onChanged: (value) {
                    setState(() {
                      _timerEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFF1B383A),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Выбор времени (если таймер включен)
            if (_timerEnabled)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimerOption('__ мүнөт', _selectedDuration),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTimerOption('1 мүнөт', _selectedDuration),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:
                            _buildTimerOption('30 секунд', _selectedDuration),
                      ),
                    ],
                  ),

                  // Поле для ввода пользовательского времени
                  if (_selectedDuration == '__ мүнөт')
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.amber.shade300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                controller: _customDurationController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '10',
                                  hintStyle: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'мүнөт',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1B383A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

            const Spacer(),

            // Кнопка запуска чтения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Показать уведомление о повороте устройства
                  _showOrientationNotification(context);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF1B383A),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Баштоо',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF9EAFB2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerOption(String text, String selectedOption) {
    final isSelected = text == selectedOption;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDuration = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1B383A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  void _showOrientationNotification(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Автоматически закрываем диалог через 3 секунды
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop();

          // Переход к экрану чтения
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReadingScreen(
                title: widget.title,
                content: widget.content,
                questions: widget.questions,
                timeInSeconds: _timerEnabled ? _getDurationInSeconds() : 0,
              ),
            ),
          );
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.screen_rotation,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 15),
                Text(
                  'Устройствону горизонталдык абалга айландырыңыз',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
