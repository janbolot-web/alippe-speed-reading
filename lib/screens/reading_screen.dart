import 'dart:async';

import 'package:client/screens/questions_screen.dart';
import 'package:client/widgets/markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Класс для хранения слова, его позиции и состояния в тексте
class TextWord {
  final String word; // Оригинальное слово
  final String normalized; // Нормализованное слово для сравнения
  final int startIndex; // Начальная позиция в тексте
  final int endIndex; // Конечная позиция в тексте
  bool isRead; // Прочитано ли слово

  TextWord({
    required this.word,
    required this.normalized,
    required this.startIndex,
    required this.endIndex,
    this.isRead = false,
  });
}

class ReadingScreen extends StatefulWidget {
  final String title;
  final String content;
  final List<Map<String, dynamic>> questions;
  final int timeInSeconds;

  const ReadingScreen({
    super.key,
    required this.title,
    required this.content,
    required this.questions,
    required this.timeInSeconds,
  });

  @override
  _ReadingScreenState createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late Timer _timer;
  int _remainingSeconds = 0;
  bool _timerActive = false;

  // Список слов из исходного текста с сохранением позиций
  List<TextWord> _textWords = [];

  // Текущая позиция в списке слов
  final int _currentWordIndex = 0;

  @override
  void initState() {
    super.initState();

    // Подготавливаем слова с их позициями в тексте
    _extractWords();

    _remainingSeconds = widget.timeInSeconds;

    if (_remainingSeconds > 0) {
      _timerActive = true;
      _startTimer();
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // Метод для извлечения слов с их позициями
  void _extractWords() {
    final String text = widget.content;
    final RegExp wordRegExp = RegExp(r'\b[а-яА-Яa-zA-Z0-9]+\b');

    final Iterable<RegExpMatch> matches = wordRegExp.allMatches(text);

    _textWords = matches.map((match) {
      final String original = text.substring(match.start, match.end);
      return TextWord(
        word: original,
        normalized: original.toLowerCase(),
        startIndex: match.start,
        endIndex: match.end,
        isRead: false,
      );
    }).toList();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    if (_timerActive) {
      _timer.cancel();
    }

    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timerActive = false;
            timer.cancel();
            _navigateToQuestions();
          }
        });
      }
    });
  }

  void _navigateToQuestions() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsScreen(
          title: widget.title,
          questions: widget.questions,
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Метод для создания подсвеченного текста
  Widget _buildHighlightedText() {
    final String text = widget.content;
    List<InlineSpan> spans = [];

    int lastEnd = 0;

    // Проходим по всем словам в тексте
    for (int i = 0; i < _textWords.length; i++) {
      final TextWord word = _textWords[i];

      // Добавляем текст между предыдущим словом и текущим
      if (word.startIndex > lastEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastEnd, word.startIndex),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        );
      }

      // Добавляем текущее слово с соответствующим стилем
      spans.add(
        TextSpan(
          text: word.word,
          style: TextStyle(
            fontSize: 18,
            color: word.isRead ? Colors.grey : Colors.black,
            fontWeight:
                (i == _currentWordIndex) ? FontWeight.bold : FontWeight.normal,
            decoration: (i == _currentWordIndex)
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      );

      lastEnd = word.endIndex;
    }

    // Добавляем оставшийся текст после последнего слова
    if (lastEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastEnd),
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _timerActive ? const Color(0xffBA0F43) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _timerActive ? _formatTime(_remainingSeconds) : '00:00',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _timerActive ? Colors.white : Colors.transparent,
              ),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B383A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Подсвеченный текст вместо обычного текста
                Text(
                  widget.content,
                  style: GoogleFonts.montserrat(fontSize: 30),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_timerActive) {
                        _timer.cancel();
                        _timerActive = false;
                      }

                      _navigateToQuestions();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF1B383A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Финиш',
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
        ),
      ),
    );
  }
}
