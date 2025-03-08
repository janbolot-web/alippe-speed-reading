
// Экран с вопросами по тексту
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionsScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> questions;

  const QuestionsScreen({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<int?> _selectedAnswers = [];
  bool _showResults = false;
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    // Инициализируем список выбранных ответов
    _selectedAnswers = List.filled(widget.questions.length, null);

    // Возвращаем портретную ориентацию
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _checkAnswers() {
    int correct = 0;

    for (int i = 0; i < widget.questions.length; i++) {
      if (_selectedAnswers[i] != null &&
          _selectedAnswers[i] == widget.questions[i]['correctIndex']) {
        correct++;
      }
    }

    setState(() {
      _correctAnswers = correct;
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B383A)),
          onPressed: () {
            // Возвращаемся на главный экран
            Navigator.popUntil(context, (route) => route.isFirst);
          },
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Вопросы
            Text(
              'Тесттик суроолор',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B383A),
              ),
            ),
            const SizedBox(height: 20),

            // Список вопросов
            ...List.generate(widget.questions.length, (index) {
              return _buildQuestion(index);
            }),

            const SizedBox(height: 20),

            // Кнопка проверки
            if (!_showResults)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Проверяем, что все вопросы отвечены
                    if (!_selectedAnswers.contains(null)) {
                      _checkAnswers();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Бардык суроолорго жооп бериңиз'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
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

            // Результаты
            if (_showResults)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Жыйынтык',
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1B383A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_correctAnswers / ${widget.questions.length}',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _correctAnswers == widget.questions.length
                                ? Colors.green
                                : const Color(0xFF1B383A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _correctAnswers == widget.questions.length
                              ? 'Өте жакшы! Бардык суроолорго туура жооп бердиңиз!'
                              : 'Аракет кылыңыз! Дагы бир жолу окуп көрүңүз.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Возвращаемся на главный экран
                        Navigator.popUntil(context, (route) => route.isFirst);
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
                        'Кайтуу',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
  }

  Widget _buildQuestion(int index) {
    final question = widget.questions[index];
    final options = question['options'] as List<dynamic>;
    final correctIndex = question['correctIndex'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Номер и текст вопроса
          Text(
            '${index + 1}. ${question['question']}',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B383A),
            ),
          ),
          const SizedBox(height: 10),

          // Варианты ответов
          ...List.generate(options.length, (optionIndex) {
            final isSelected = _selectedAnswers[index] == optionIndex;
            final isCorrect = optionIndex == correctIndex;
            final isWrong = _showResults && isSelected && !isCorrect;

            Color backgroundColor = Colors.transparent;
            if (_showResults) {
              if (isCorrect) {
                backgroundColor = Colors.green.withOpacity(0.1);
              } else if (isWrong) {
                backgroundColor = Colors.red.withOpacity(0.1);
              }
            } else if (isSelected) {
              backgroundColor = Colors.blue.withOpacity(0.1);
            }

            return GestureDetector(
              onTap: _showResults
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswers[index] = optionIndex;
                      });
                    },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Иконка результата (если показываем результаты)
                    if (_showResults)
                      Icon(
                        isCorrect
                            ? Icons.check_circle
                            : (isWrong ? Icons.cancel : null),
                        color: isCorrect
                            ? Colors.green
                            : (isWrong ? Colors.red : null),
                      ),

                    // Буква варианта
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          String.fromCharCode(65 + optionIndex), // A, B, C, D
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),

                    // Текст варианта
                    Expanded(
                      child: Text(
                        options[optionIndex],
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: const Color(0xFF1B383A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
