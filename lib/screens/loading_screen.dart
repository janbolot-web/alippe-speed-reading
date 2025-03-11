// Экран загрузки и обработки результатов от ChatGPT
import 'package:client/screens/preview_screen.dart';
import 'package:client/screens/timer_setup_screen.dart';
import 'package:client/seriveces.dart';
import 'package:client/widgets/markdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoadingScreen extends StatefulWidget {
  final String classLevel;
  final String questionsCount;
  final String language;

  const LoadingScreen({
    super.key,
    required this.classLevel,
    required this.questionsCount,
    required this.language,
  });

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Для хранения данных, полученных от API
  String _title = '';
  String _content = '';
  String _imageUrl = '';
  List<Map<String, dynamic>> _questions = [];

  // Для постепенного отображения полученного текста
  String _partialContent = '';

  @override
  void initState() {
    super.initState();
    _fetchContentFromChatGPT();
  }

// Исправленный метод для извлечения информации из неструктурированного ответа
  void _extractInformation() {
    final text = _partialContent;

    print(
        "Пытаемся извлечь информацию из ответа длиной ${text.length} символов");

    // Простая эвристика для извлечения заголовка, содержания и вопросов
    try {
      // Ищем заголовок (обычно в начале, до первого абзаца)
      final titleEnd = text.indexOf('\n\n');
      if (titleEnd > 0) {
        _title = text.substring(0, titleEnd).trim();
      } else {
        _title = 'Сказка';
      }

      print("Извлеченный заголовок: $_title");

      // Ищем начало вопросов (обычно после фразы "Вопросы:" или подобной)
      int questionsStart = text.indexOf('Вопросы:');
      if (questionsStart == -1) {
        questionsStart = text.indexOf('Суроолор:');
      }
      if (questionsStart == -1) {
        final lastDoubleNewline = text.lastIndexOf('\n\n');
        questionsStart =
            lastDoubleNewline > 0 ? lastDoubleNewline : text.length;
      }

      print("Начало вопросов найдено на позиции: $questionsStart");

      if (questionsStart > 0 && titleEnd > 0 && questionsStart > titleEnd) {
        // У нас есть валидные индексы для извлечения контента
        _content = text.substring(titleEnd, questionsStart).trim();

        print("Извлечено содержание длиной: ${_content.length}");

        // Создаем примерные вопросы на основе текста
        _questions = [
          {
            'question': 'Вопрос о содержании сказки?',
            'options': ['Вариант A', 'Вариант B', 'Вариант C', 'Вариант D'],
            'correctIndex': 0
          },
          {
            'question': 'Еще один вопрос по сказке?',
            'options': ['Вариант 1', 'Вариант 2', 'Вариант 3', 'Вариант 4'],
            'correctIndex': 1
          }
        ];
      } else if (titleEnd > 0) {
        // У нас есть только заголовок, используем весь остальной текст как контент
        _content = text.substring(titleEnd).trim();
        _questions = [];

        print("Извлечено содержание без вопросов, длина: ${_content.length}");
      } else {
        // Не удалось найти структуру, используем весь текст как контент
        _title = "Сказка";
        _content = text.trim();
        _questions = [];

        print("Не удалось найти структуру, используем весь текст как контент");
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Ошибка при извлечении информации: $e');
      print('Текст ответа: $text');

      // В случае ошибки используем демо-данные
    }
  }

// Обновленный метод _fetchContentFromChatGPT для лучшей диагностики
  Future<void> _fetchContentFromChatGPT() async {
    setState(() {
      _isLoading = true;
      _partialContent = '';
      _hasError = false;
      _imageUrl = '';
    });

    try {
      print("Начинаем запрос к ChatGPT...");

      // Подписываемся на поток ответов от ChatGPT
      await for (final chunk in ChatGPTService.generateEducationalContent(
        classLevel: widget.classLevel,
        questionsCount: widget.questionsCount,
        language: widget.language,
      )) {
        setState(() {
          _partialContent = chunk;
        });
      }

      print(
          "Получен полный ответ от ChatGPT. Длина: ${_partialContent.length}");
      print(
          "Первые 100 символов: ${_partialContent.substring(0, _partialContent.length > 100 ? 100 : _partialContent.length)}");

      // После получения всего контента, парсим JSON
      try {
        print("Пытаемся распарсить ответ как JSON...");
        final parsedData = ChatGPTService.parseContentText(
            _partialContent, widget.questionsCount);

        setState(() {
          _title = parsedData['title'];
          _content = parsedData['content'];
          _questions = List<Map<String, dynamic>>.from(parsedData['questions']);
          _isLoading = false;
        });

        print("JSON успешно распарсен. Заголовок: $_title");

        // Генерируем или выбираем изображение
        _generateImage();
      } catch (e) {
        print('Ошибка парсинга JSON: $e');

        // Если ответ не в формате JSON, пытаемся извлечь информацию другим способом
        print("Пробуем альтернативный метод извлечения информации...");
        _extractInformation();
      }
    } catch (e) {
      print('Ошибка при получении данных: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Ошибка при получении данных: $e';
      });
    }
  }

  Future<String> _generateOrUseLocalImage() async {
    try {
      // Пытаемся сгенерировать изображение с помощью API
      final imageUrl = await ChatGPTService.generateImage(
        title: _title,
        content: _content,
        language: widget.language,
      );

      print("Изображение успешно сгенерировано: $imageUrl");
      return imageUrl;
    } catch (e) {
      print("Ошибка при генерации изображения: $e");

      // В случае ошибки генерации возвращаем пустую строку
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _isLoading
          ? SafeArea(child: _buildLoadingView())
          : _hasError
              ? _buildErrorView()
              : SafeArea(child: _buildContentView()),
    );
  }

  Widget _buildLoadingView() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B383A)),
            ),
            const SizedBox(height: 20),
            Text(
              'Текст түзүлүүдө...',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                color: const Color(0xFF1B383A),
              ),
            ),
            if (_partialContent.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  _partialContent,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            'Ката кетти',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _errorMessage = '';
                _partialContent = '';
              });
              _fetchContentFromChatGPT();
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF1B383A),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Кайра аракет кылуу'),
          ),
        ],
      ),
    );
  }

  Widget _buildContentView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхний блок с иллюстрацией
            // Верхний блок с иллюстрацией
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B383A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _imageUrl.isEmpty
                    ? _buildImageSkeleton() // Показываем скелетон во время загрузки
                    : _imageUrl.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              _imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return _buildImageLoadingIndicator(
                                    loadingProgress);
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print("Ошибка загрузки изображения: $error");
                                return _buildDefaultImage();
                              },
                            ),
                          )
                        : _buildDefaultImage(),
              ),
            ),
            const SizedBox(height: 20),

            // Заголовок
            Center(
              child: MarkdownTextWidget(
                textAlignCenter: true,
                text: _title,
                textStyle: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xff1B434D),
                ),
                selectable: true,
              ),
            ),

            Center(
              child: Text(
                widget.language == 'Кыргыз' ? 'Илимий текст' : 'Сказка',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: const Color(0xff1B434D),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Информация о классе, количестве слов и вопросов
            Row(
              children: [
                _buildInfoItem('${widget.classLevel}-класс'),
                const SizedBox(width: 10),
                _buildInfoItem('120 сөз'),
                const SizedBox(width: 10),
                _buildInfoItem('${_questions.length} суроо'),
              ],
            ),

            const SizedBox(height: 20),

            // Текст сказки/статьи
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
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
              child: MarkdownTextWidget(
                textAlignCenter: false,
                text: _content,
                textStyle: GoogleFonts.montserrat(
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff1B434D),
                ),
                selectable: true,
              ),
            ),

            const SizedBox(height: 30),

            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Переход к предпросмотру текста и вопросов
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PreviewScreen(
                            title: _title,
                            content: _content,
                            questions: _questions,
                            classLevel: widget.classLevel,
                            wordsCount: '120',
                            questionsCount: widget.questionsCount,
                          ),
                        ),
                      );

                      // Обновление данных, если они были изменены
                      if (result != null && result is Map<String, dynamic>) {
                        setState(() {
                          _title = result['title'];
                          _content = result['content'];
                          _questions = result['questions'];
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B383A),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFF1B383A)),
                      ),
                    ),
                    child: const Text(
                      'Көрүү',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Переход к экрану настройки времени чтения
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimerSetupScreen(
                            title: _title,
                            content: _content,
                            questions: _questions,
                            classLevel: widget.classLevel,
                            wordsCount: '120',
                          ),
                        ),
                      );
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
          ],
        ),
      ),
    );
  }

// Заглушка для изображения, если не удается загрузить
  Widget _buildDefaultImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: const Color(0xFF1B383A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, color: Colors.white.withOpacity(0.7), size: 48),
              const SizedBox(height: 10),
              Text(
                widget.language == 'Кыргыз'
                    ? 'Сүрөт генерацияланбай калды'
                    : 'Изображение не сгенерировано',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateImage() async {
    try {
      setState(() {
        _imageUrl = ""; // Пустая строка, показываем анимированный лоадинг
      });

      // // Генерируем изображение через API
      // final imageUrl = await ChatGPTService.generateImage(
      //   title: _title,
      //   content: _content,
      //   language: widget.language,
      // );

      // setState(() {
      //   _imageUrl = imageUrl;
      // });
    } catch (e) {
      print('Ошибка при генерации изображения: $e');
      setState(() {
        _imageUrl = ""; // Показать анимацию загрузки еще на 2 секунды
      });

      // Имитация задержки перед показом ошибки
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _imageUrl = "error"; // Любое значение, которое не начинается с http
      });
    }
  }

  Widget _buildInfoItem(String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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

  // Замените _buildImageSkeleton на этот метод с красивой анимацией

  Widget _buildImageSkeleton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF1B383A),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Красивая анимация загрузки
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Внешний вращающийся круг
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 2 * 3.14159),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value,
                        child: child,
                      );
                    },
                    onEnd: () {
                      setState(() {});
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 4,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9EAFB2), Colors.transparent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),

                  // Внутренний пульсирующий круг
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.7, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    onEnd: () {
                      setState(() {});
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF1B383A),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.image,
                          color: Colors.white.withOpacity(0.7),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Бегущие точки для индикации загрузки
            SizedBox(
              width: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.3, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                    onEnd: () {
                      // Запускаем заново с задержкой для каждой точки
                      if (index == 2) {
                        setState(() {});
                      }
                    },
                  );
                }),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              widget.language == 'Кыргыз'
                  ? 'Сүрөт түзүлүүдө...'
                  : 'Создание изображения...',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Улучшенный индикатор загрузки
  Widget _buildImageLoadingIndicator(ImageChunkEvent loadingProgress) {
    // Вычисляем прогресс загрузки
    final double progress = loadingProgress.expectedTotalBytes != null
        ? loadingProgress.cumulativeBytesLoaded /
            loadingProgress.expectedTotalBytes!
        : 0.0;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Кастомный индикатор прогресса
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1B383A),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Круговой прогресс
                CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? progress
                      : null,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF9EAFB2)),
                  strokeWidth: 6,
                ),

                // Процент загрузки
                if (loadingProgress.expectedTotalBytes != null)
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            widget.language == 'Кыргыз'
                ? 'Сүрөт жүктөлүүдө...'
                : 'Загрузка изображения...',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

// Также не забудьте обновить метод _generateImage:
}
