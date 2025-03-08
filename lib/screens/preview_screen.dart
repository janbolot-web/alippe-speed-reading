// Экран предпросмотра текста и вопросов
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PreviewScreen extends StatefulWidget {
  final String title;
  final String content;
  final List<Map<String, dynamic>> questions;
  final String classLevel;
  final String wordsCount;
  final String questionsCount;

  const PreviewScreen({
    super.key,
    required this.title,
    required this.content,
    required this.questions,
    required this.classLevel,
    required this.wordsCount,
    required this.questionsCount,
  });

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  List<Map<String, dynamic>> _editableQuestions = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _contentController = TextEditingController(text: widget.content);

    // Создаем копию вопросов для редактирования
    _editableQuestions =
        List.from(widget.questions.map((q) => Map<String, dynamic>.from(q)));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
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
          'Предпросмотр',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B383A),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              'Заголовок',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B383A),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 20),

            // Информация о тексте
            Row(
              children: [
                _buildInfoItem('${widget.classLevel}-класс'),
                const SizedBox(width: 10),
                _buildInfoItem('${widget.wordsCount} сөз'),
                const SizedBox(width: 10),
                _buildInfoItem('${widget.questionsCount} суроо'),
              ],
            ),

            const SizedBox(height: 20),

            // Текст контента
            Text(
              'Текст',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B383A),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _contentController,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: Colors.grey[800],
              ),
              maxLines: 10,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 30),

            // Вопросы
            Text(
              'Тесттик суроолор',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B383A),
              ),
            ),
            const SizedBox(height: 16),

            ...List.generate(_editableQuestions.length, (index) {
              return _buildQuestionEditor(index);
            }),

            const SizedBox(height: 30),

            // Кнопка сохранения
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Сохраняем изменения и возвращаемся назад с обновленными данными
                  Navigator.pop(context, {
                    'title': _titleController.text,
                    'content': _contentController.text,
                    'questions': _editableQuestions,
                  });
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
                  'Сактоо',
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

  Widget _buildQuestionEditor(int index) {
    final question = _editableQuestions[index];
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
          // Номер вопроса
          Text(
            '${index + 1} - Суроо',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // Текст вопроса
          TextFormField(
            initialValue: question['question'],
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: Colors.grey[800],
            ),
            onChanged: (value) {
              setState(() {
                question['question'] = value;
              });
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 16),

          // Варианты ответов
          ...List.generate(options.length, (optionIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // Радиокнопка для выбора правильного ответа
                  Radio<int>(
                    value: optionIndex,
                    groupValue: correctIndex,
                    activeColor: const Color(0xFF1B383A),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          question['correctIndex'] = value;
                        }
                      });
                    },
                  ),

                  // Поле ввода варианта ответа
                  Expanded(
                    child: TextFormField(
                      initialValue: options[optionIndex].toString(),
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                      onChanged: (value) {
                        setState(() {
                          options[optionIndex] = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
