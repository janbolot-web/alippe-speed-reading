import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:client/api_config.dart';
import 'package:client/screens/questions_screen.dart';
import 'package:client/widgets/markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

// Класс для распознавания речи с использованием Whisper API
class SpeechRecognitionService {
  static const String _whisperEndpoint = '/audio/transcriptions';
  static const String _whisperModel = 'whisper-1';

  // Экземпляр рекордера для записи аудио
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String? _audioPath;
  bool _isRecording = false;

  // Инициализация рекордера
  // Исправленный метод инициализации рекордера в классе SpeechRecognitionService
  Future<void> initialize() async {
    try {
      // 1. Проверяем текущий статус разрешений
      print('Проверка статуса разрешения микрофона...');
      PermissionStatus micPermission = await Permission.microphone.status;
      print('Текущий статус разрешения микрофона: $micPermission');

      // 2. Если разрешение еще не предоставлено, запрашиваем его
      if (micPermission != PermissionStatus.granted) {
        print('Запрашиваем разрешение на использование микрофона...');
        micPermission = await Permission.microphone.request();
        print('Новый статус разрешения микрофона: $micPermission');
      }

      // 3. Если после запроса разрешение не предоставлено, обрабатываем различные случаи
      if (micPermission != PermissionStatus.granted) {
        if (micPermission == PermissionStatus.denied) {
          throw Exception('Пользователь отклонил доступ к микрофону');
        } else if (micPermission == PermissionStatus.permanentlyDenied) {
          throw Exception(
              'Доступ к микрофону запрещен навсегда. Пожалуйста, разрешите в настройках устройства');
        } else {
          throw Exception(
              'Доступ к микрофону не предоставлен (статус: $micPermission)');
        }
      }

      // 4. Пробуем получить также разрешение на хранилище (для старых версий Android)
      print('Запрашиваем разрешение на хранилище...');
      await Permission.storage.request();

      // 5. Инициализируем рекордер
      print('Инициализация рекордера...');
      try {
        await _recorder.openRecorder();
        print('Рекордер инициализирован успешно');
      } catch (e) {
        if (e.toString().contains('already open')) {
          print('Рекордер уже был инициализирован');
        } else {
          print('Ошибка при открытии рекордера: $e');
          rethrow;
        }
      }
    } catch (e) {
      print('Ошибка при инициализации рекордера: $e');
      throw Exception('Не удалось инициализировать рекордер: $e');
    }
  }

// Исправленный метод начала записи

// Исправленный метод начала записи
  Future<void> startRecording() async {
    try {
      // Проверяем, не идет ли уже запись
      if (_recorder.isRecording) {
        print('Запись уже идет');
        return;
      }

      // Получаем путь к временному файлу
      final Directory tempDir = await getTemporaryDirectory();
      _audioPath = '${tempDir.path}/audio_recording.wav';
      print('Путь для аудиозаписи: $_audioPath');

      // Начинаем запись
      await _recorder.startRecorder(
        toFile: _audioPath,
        codec: Codec.pcm16WAV,
      );

      _isRecording = true;
      print('Запись началась');
    } catch (e) {
      print('Ошибка при начале записи: $e');
      throw Exception('Не удалось начать запись: $e');
    }
  }

  // Остановить запись и получить транскрипцию
  Future<String> stopRecordingAndTranscribe() async {
    try {
      if (_recorder.isRecording) {
        print('Останавливаем запись');
        // Останавливаем запись
        await _recorder.stopRecorder();
        _isRecording = false;

        if (_audioPath != null) {
          // Отправляем аудио в Whisper API
          print('Отправляем аудиофайл в Whisper API');
          final transcription = await _sendToWhisperAPI(_audioPath!);
          return transcription;
        }
      }
      return '';
    } catch (e) {
      print('Ошибка при остановке записи и транскрибации: $e');
      throw Exception('Ошибка при получении транскрипции: $e');
    }
  }

  // Освобождение ресурсов
  Future<void> dispose() async {
    try {
      await _recorder.closeRecorder();
      print('Рекордер освобожден');
    } catch (e) {
      print('Ошибка при освобождении рекордера: $e');
    }
  }

 Future<String> _sendToWhisperAPI(String audioFilePath) async {
  try {
    final url = Uri.parse('${ApiConfig.baseUrl}${_whisperEndpoint}');
    print('URL для Whisper API: $url');

    // Подготавливаем файл для отправки
    final file = File(audioFilePath);
    
    if (!await file.exists()) {
      throw Exception('Аудиофайл не существует: $audioFilePath');
    }
    
    // Создаем multipart request
    final request = http.MultipartRequest('POST', url);
    
    // Устанавливаем правильные заголовки для авторизации
    request.headers['Authorization'] = 'Bearer ${ApiConfig.apiKey}';
    
    // Важно: не устанавливаем Content-Type заголовок,
    // он будет установлен автоматически с правильной границей (boundary)

    // Добавляем файл как multipart параметр
    request.files.add(await http.MultipartFile.fromPath(
      'file',  // имя поля должно быть 'file'
      audioFilePath,
    ));

    // Добавляем остальные параметры
    request.fields['model'] = _whisperModel;
    request.fields['language'] = 'ru';  // или 'ky' для кыргызского
    request.fields['response_format'] = 'json';  // явно указываем формат ответа

    // Отправляем запрос
    print('Отправляем запрос на транскрипцию...');
    final streamedResponse = await request.send();
    
    // Получаем ответ
    final response = await http.Response.fromStream(streamedResponse);
    print('Статус ответа: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final text = jsonResponse['text'] ?? '';
      print('Распознанный текст: $text');
      return text;
    } else {
      print('Ошибка API: ${response.statusCode}, тело: ${response.body}');
      throw Exception('Ошибка API при транскрипции: ${response.statusCode}');
    }
  } catch (e) {
    print('Ошибка при отправке аудио в Whisper API: $e');
    throw Exception('Не удалось распознать речь: $e');
  }
}
  // Геттер для проверки статуса записи
  bool get isRecording => _isRecording;
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

  // Добавляем сервис распознавания речи
  late SpeechRecognitionService _speechService;

  // Состояние проверки
  bool _isListening = false;
  String _recognizedText = '';

  // Map для отслеживания прочитанных слов
  final Map<String, bool> _wordReadStatus = {};

  @override
  void initState() {
    super.initState();
    super.initState();

    // Инициализируем сервис
    _speechService = SpeechRecognitionService();

    void showPermissionSettingsDialog() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Разрешение на доступ к микрофону'),
            content: const Text(
              'Для распознавания речи необходимо разрешение на доступ к микрофону. '
              'Пожалуйста, разрешите доступ в настройках приложения.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Открыть настройки'),
              ),
            ],
          );
        },
      );
    }

    // Инициализируем асинхронно и обрабатываем ошибки
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _speechService.initialize();
        print('Сервис распознавания успешно инициализирован');
      } catch (e) {
        print('Ошибка при инициализации сервиса распознавания: $e');

        // Если ошибка связана с разрешениями, показываем диалог настроек
        if (mounted) {
          if (e.toString().contains('микрофон')) {
            showPermissionSettingsDialog();
          } else {
            // Для других ошибок показываем стандартное сообщение
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка инициализации: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    });

    // Подготавливаем слова с их позициями в тексте
    _extractWords();

    // Инициализируем статус прочтения для каждого слова
    for (final word in _textWords) {
      _wordReadStatus[word.normalized] = false;
    }

    // Инициализируем таймер
    _remainingSeconds = widget.timeInSeconds;

    if (_remainingSeconds > 0) {
      _timerActive = true;
      _startTimer();
    }

    // Устанавливаем ориентацию экрана
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

    _speechService.dispose();
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

// В методе _startListening класса _ReadingScreenState тоже убираем проверку isInitialized
  void _startListening() async {
    if (!_isListening) {
      setState(() {
        _isListening = true;
        _recognizedText = 'Слушаю...';
      });

      try {
        // Просто начинаем запись, внутри метода уже есть все проверки
        await _speechService.startRecording();
      } catch (e) {
        setState(() {
          _isListening = false;
          _recognizedText = 'Ошибка при начале записи: $e';
        });

        // Показываем ошибку пользователю
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка микрофона: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Остановить слушание и проверить прочитанное
  void _stopListeningAndCheckReading() async {
    if (_isListening) {
      setState(() {
        _isListening = false;
        _recognizedText = 'Обработка...';
      });

      try {
        // Получаем текст из аудио
        final transcription = await _speechService.stopRecordingAndTranscribe();

        setState(() {
          _recognizedText = transcription;
        });

        // Проверяем произнесенные слова
        _checkReadWords(transcription);
      } catch (e) {
        setState(() {
          _recognizedText = 'Ошибка распознавания: $e';
        });
      }
    }
  }

  // Проверяем, какие слова были прочитаны правильно
  void _checkReadWords(String recognizedText) {
    // Нормализуем и разбиваем распознанный текст на слова
    final normalizedRecognized = recognizedText.toLowerCase();
    final recognizedWords = _extractWordsFromString(normalizedRecognized);

    // Помечаем слова как прочитанные
    int readWordsCount = 0;
    for (final textWord in _textWords) {
      if (recognizedWords.contains(textWord.normalized)) {
        setState(() {
          textWord.isRead = true;
          _wordReadStatus[textWord.normalized] = true;
          readWordsCount++;
        });
      }
    }

    // Обновляем UI с новым статусом слов и показываем результат
    setState(() {
      _recognizedText =
          '$_recognizedText\n\nРаспознано $readWordsCount из ${_textWords.length} слов';
    });
  }

  // Вспомогательный метод для извлечения слов из строки
  Set<String> _extractWordsFromString(String text) {
    final Set<String> words = {};
    final RegExp wordRegExp = RegExp(r'\b[а-яА-Яa-zA-Z0-9]+\b');

    final Iterable<RegExpMatch> matches = wordRegExp.allMatches(text);
    for (final match in matches) {
      final String word = text.substring(match.start, match.end).toLowerCase();
      words.add(word);
    }

    return words;
  }

  // Метод для создания подсвеченного текста с отметкой о прочитанных словах
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
              fontSize: 30,
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
            fontSize: 30,
            color: word.isRead ? Colors.green : Colors.black,
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
            fontSize: 30,
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
              color:
                  _timerActive ? const Color(0xffBA0F43) : Colors.transparent,
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
        child: Column(
          children: [
            // Область для текста
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Используем подсвеченный текст вместо обычного
                      _buildHighlightedText(),
                    ],
                  ),
                ),
              ),
            ),

            // Область распознанного текста
            if (_recognizedText.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[200],
                width: double.infinity,
                child: Text(
                  _recognizedText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            // Панель управления с кнопками
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Кнопка слушать/стоп
                  ElevatedButton.icon(
                    onPressed: _isListening
                        ? _stopListeningAndCheckReading
                        : _startListening,
                    icon: Icon(_isListening ? Icons.stop : Icons.mic),
                    label: Text(_isListening ? 'Стоп' : 'Слушать'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          _isListening ? Colors.red : const Color(0xFF1B383A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                  ),

                  // Кнопка финиш (существующая)
                  ElevatedButton(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
