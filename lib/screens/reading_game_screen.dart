
import 'package:client/screens/loading_screen.dart';
import 'package:client/utils/flower_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReadingGameScreen extends StatefulWidget {
  const ReadingGameScreen({super.key});

  @override
  _ReadingGameScreenState createState() => _ReadingGameScreenState();
}

class _ReadingGameScreenState extends State<ReadingGameScreen>
    with SingleTickerProviderStateMixin {
  String? selectedClass;
  String? selectedLevel;
  String? selectedLanguage;
  bool showGenres = false;
  bool showFullDescription = false;

  // Контроллер анимации для плавного раскрытия текста
  late AnimationController _controller;
  late Animation<double> _animation;

  final String fullDescription =
      'Бул бөлүмдө жасалма интеллект 1-4-класстын окуучулары үчүн окуу ылдамдыгын текшерүү максатында ар кандай жанрда текст түзүп берет. Түзүлгөн текстти окуучунун деңгээлине жараша убакытка ченеп окутсаңыз болот. Текстти окуп бүткөн соң окуучулар жасалма интеллект тексттин негизинде түзүп берген тестти иштеп, түшүнүгүн текшере алышат. Келиңиз чогу "Шар окуу" оюнун чогу түзөбүз.';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleDescription() {
    setState(() {
      showFullDescription = !showFullDescription;
      if (showFullDescription) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff49295A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Верхний стек с изображением и заголовком
            _buildHeaderSection(),

            const SizedBox(height: 20),

            // Информационный контейнер с раскрывающимся текстом
            _buildExpandableDescription(),

            const SizedBox(height: 20),

            // Выбор класса, уровня и языка
            _buildSelectionRow(),

            const SizedBox(height: 10),

            // Выбор жанра
            _buildGenreSection(),

            const SizedBox(height: 20),

            // Кнопка генерации
            _buildGenerateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Stack(
      children: [
        Image.asset(
          'assets/images/girl.png',
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 300,
              width: double.infinity,
              color: Colors.purple.shade300,
              child: CustomPaint(
                painter: FlowerPainter(),
                child: Center(
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 248,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0xFF49295A),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Шар окуу оюнун түзүү',
                    style: GoogleFonts.montserrat(
                      fontSize: 35,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandableDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Основной контейнер, который всегда виден
          GestureDetector(
            onTap: _toggleDescription,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: showFullDescription
                    ? const BorderRadius.vertical(top: Radius.circular(10))
                    : BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fullDescription,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    showFullDescription
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),

          // Анимированное раскрытие полного текста
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  heightFactor: _animation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(10)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Создаем TextSpan для измерения видимой части текста
                  final textSpan = TextSpan(
                    text: fullDescription,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  );

                  // Создаем TextPainter для измерения текста
                  final textPainter = TextPainter(
                    text: textSpan,
                    textDirection: TextDirection.ltr,
                    maxLines: 3,
                  );

                  // Измеряем, сколько текста помещается в 3 строки
                  textPainter.layout(maxWidth: constraints.maxWidth);

                  // Получаем позицию конца видимого текста
                  final positionOffset = textPainter.getPositionForOffset(
                      Offset(constraints.maxWidth, textPainter.height));
                  final visibleTextLength = positionOffset.offset;

                  // Отображаем только продолжение текста
                  return Text(
                    fullDescription.substring(visibleTextLength),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdownButton(
                'Класс',
                selectedClass,
                ['1', '2', '3', '4'],
                (value) => setState(() => selectedClass = value)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdownButton(
                'Суроо',
                selectedLevel,
                ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
                (value) => setState(() => selectedLevel = value)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildDropdownButton(
                'Тили',
                selectedLanguage,
                ['Кыргыз', 'Русский'],
                (value) => setState(() => selectedLanguage = value)),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () {
              setState(() {
                showGenres = !showGenres;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'Текстин жанры',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        if (showGenres)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGenreDescription(
                    'Жомок',
                    'Фантазияга негизделген кызыктуу окуялар.',
                  ),
                  _buildGenreDescription(
                    'Ыр',
                    'Рифмалуу жана ритмдүү текст.',
                  ),
                  _buildGenreDescription(
                    'Аңгеме',
                    'Кыска, түшүнүктүү окуя.',
                  ),
                  _buildGenreDescription(
                    'Эссе',
                    'Жеке ойлор жана сезимдер жазылган текст.',
                  ),
                  _buildGenreDescription(
                    'Сүреттөмө текст',
                    'Бир нерсени сүрөттөп берүүчү жазуу.',
                  ),
                  _buildGenreDescription(
                    'Күнүмдүк жашоо баяны',
                    'Жашоодон алынган кыска окуялар.',
                  ),
                  _buildGenreDescription(
                    'Кат',
                    'Досторго же үй-бүлөгө арналган кыска билдирүүлөр.',
                  ),
                  _buildGenreDescription(
                    'Илимий текстер',
                    'Илим-билимге байланыштуу маалыматтык текстер.',
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () {
          // Проверить, выбраны ли все необходимые поля
          if (selectedClass == null ||
              selectedLevel == null ||
              selectedLanguage == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Сураныч, бардык параметрлерди тандаңыз'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          // Перейти на экран генерации контента
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoadingScreen(
                classLevel: selectedClass!,
                questionsCount: selectedLevel!,
                language: selectedLanguage!,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.deepPurple,
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: const Text(
          'Генерациялоо',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownButton(String hint, String? value, List<String> items,
      Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.white),
          ),
          value: value,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          dropdownColor: Colors.deepPurple,
          style: const TextStyle(color: Colors.white),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGenreDescription(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.montserrat(
              color: const Color(0xff49295A),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: GoogleFonts.montserrat(
              color: const Color(0xff49295A),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
