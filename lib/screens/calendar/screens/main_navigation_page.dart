// Основная страница с навигацией
import 'package:client/screens/calendar/calendar.dart';
import 'package:client/screens/calendar/screens/calendar_page.dart';
import 'package:client/screens/calendar/screens/section_page.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  // Текущий выбранный индекс
  int _selectedIndex = 5; // Начинаем с календаря (последний индекс)

  // Список праздников
  final Map<DateTime, List<String>> _holidays = {
    DateTime(2025, 2, 23): ['Праздник'],
    DateTime(2025, 3, 8): ['Международный женский день'],
    DateTime(2025, 5, 1): ['Праздник весны и труда'],
    DateTime(2025, 5, 9): ['День Победы'],
  };

  // Начальный список разделов с задачами
  List<Section> _sections = [];

  // Список элементов расписания
  List<ScheduleItem> _scheduleItems = [];

  // Контроллер для прокрутки боковой панели
  final ScrollController _sidebarScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Инициализируем данные при старте
    _initData();
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    super.dispose();
  }

  // Метод для инициализации тестовых данных
  void _initData() {
    // Создаем разделы
    _sections = [
      Section(
        id: 'work',
        title: 'Жумуш',
        letter: 'Ж',
        color: const Color(0xFFFFC107),
      ),
      Section(
        id: 'family',
        title: 'Үй-бүлө',
        letter: 'Ү',
        color: Colors.blue,
      ),
      Section(
        id: 'business',
        title: 'Бизнес',
        letter: 'Б',
        color: Colors.red,
      ),
      Section(
        id: 'development',
        title: 'Өнүгүү',
        letter: 'Ө',
        color: Colors.teal,
      ),
    ];

    // Добавляем тестовые задачи
    _addTaskToSection(
      'work',
      'Класс сабактары проекттерин иштеп чыгуу',
      DateTime(2025, 2, 20),
      '10:00',
      true,
    );

    _addTaskToSection(
      'work',
      'Ата-энелер менен жыйналышына катышуу',
      DateTime(2025, 2, 20),
      '14:00',
      true,
    );

    _addTaskToSection(
      'family',
      'Азыктарды дүкөнгө чогултуу',
      DateTime(2025, 2, 21),
      '11:00',
      false,
    );

    _addTaskToSection(
      'business',
      'Жаңылыктарды баяндамаларды тапшырма жазуу',
      DateTime(2025, 2, 22),
      '09:00',
      true,
    );

    _addTaskToSection(
      'development',
      'Жаңы китеп окуу',
      DateTime(2025, 2, 23),
      '20:00',
      false,
    );

    // Инициализируем расписание
    _scheduleItems = [
      ScheduleItem(
        id: 'class1',
        time: '8:00 - 8:45',
        subject: 'Алгебра',
        classInfo: '6-кл',
        date: DateTime(2025, 2, 20),
      ),
      ScheduleItem(
        id: 'class2',
        time: '9:50 - 10:35',
        subject: 'Алгебра',
        classInfo: '9-кл',
        date: DateTime(2025, 2, 20),
      ),
      ScheduleItem(
        id: 'task1',
        time: '11:00 - 12:00',
        subject: 'Класстык журналды толтуруу',
        classInfo: '',
        date: DateTime(2025, 2, 20),
        isTask: true,
      ),
      ScheduleItem(
        id: 'class3',
        time: '13:30 - 14:15',
        subject: 'Геометрия',
        classInfo: '11-кл',
        date: DateTime(2025, 2, 20),
      ),
    ];
  }

  // Метод для добавления нового раздела
  void _addNewSection(String title, String letter, Color color) {
    setState(() {
      _sections.add(
        Section(
          id: 'section_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          letter: letter,
          color: color,
        ),
      );
      // Автоматически переключаемся на новый раздел
      _selectedIndex = _sections.length - 1;
      
      // Прокручиваем к новому разделу после добавления
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedSection();
      });
    });
  }

  // Метод для прокрутки к выбранному разделу
  void _scrollToSelectedSection() {
    if (_selectedIndex < _sections.length) {
      // Расчетная позиция для прокрутки (высота кнопки + отступ) × индекс
      final double position = (_selectedIndex * (42.0 + 16.0));
      
      // Прокручиваем до нужной позиции с анимацией
      _sidebarScrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Метод для добавления задачи в раздел
  void _addTaskToSection(
    String sectionId,
    String title,
    DateTime date,
    String time,
    bool isUrgent,
  ) {
    setState(() {
      final sectionIndex = _sections.indexWhere((s) => s.id == sectionId);
      if (sectionIndex != -1) {
        final section = _sections[sectionIndex];

        section.tasks.add(
          Task(
            id: 'task_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            date: date,
            time: time,
            isUrgent: isUrgent,
            sectionId: sectionId,
            sectionTitle: section.title,
            sectionColor: section.color,
          ),
        );
      }
    });
  }

  // Метод для получения всех задач из всех разделов для конкретной даты
  List<Task> _getTasksForDate(DateTime date) {
    final List<Task> tasksForDate = [];

    for (final section in _sections) {
      for (final task in section.tasks) {
        if (isSameDay(task.date, date)) {
          tasksForDate.add(task);
        }
      }
    }

    // Сортируем задачи по времени
    tasksForDate.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));

    return tasksForDate;
  }

  // Метод для добавления элемента расписания
  void _addScheduleItem(
      String time, String subject, String classInfo, DateTime date) {
    setState(() {
      _scheduleItems.add(
        ScheduleItem(
          id: 'schedule_${DateTime.now().millisecondsSinceEpoch}',
          time: time,
          subject: subject,
          classInfo: classInfo,
          date: date,
        ),
      );
    });
  }

  // Метод для получения элементов расписания для конкретной даты
  List<ScheduleItem> _getScheduleItemsForDate(DateTime date) {
    final List<ScheduleItem> itemsForDate = [];

    // Добавляем предметы из расписания
    for (final item in _scheduleItems) {
      if (isSameDay(item.date, date)) {
        itemsForDate.add(item);
      }
    }

    // Добавляем задачи из разделов
    for (final task in _getTasksForDate(date)) {
      itemsForDate.add(ScheduleItem.fromTask(task));
    }

    // Сортируем по времени
    return ScheduleItem.sortByTime(itemsForDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // Если выбран календарь (последний элемент)
    if (_selectedIndex == _sections.length + 1) {
      return CalendarPage(
        onAddScheduleItem: _addScheduleItem,
        getScheduleItemsForDate: _getScheduleItemsForDate,
        scheduleItems: _scheduleItems,
        holidays: _holidays,
      );
    }
    // Если выбрана страница добавления раздела
    else if (_selectedIndex == _sections.length) {
      return AddSectionPage(onSectionAdded: _addNewSection);
    }
    // Иначе отображаем страницу раздела
    else if (_selectedIndex < _sections.length) {
      return SectionPage(
        section: _sections[_selectedIndex],
        onAddTask: (title, date, time, isUrgent) => _addTaskToSection(
          _sections[_selectedIndex].id,
          title,
          date,
          time,
          isUrgent,
        ),
      );
    }
    // Защита от ошибок
    else {
      return const Center(
        child: Text('Страница не найдена'),
      );
    }
  }

  Widget _buildSidebar() {
    return Container(
      width: 70,
      color: const Color(0xff1B434D),
      child: Column(
        children: [
          const SizedBox(height: 50),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(height: 20),
          // Основная прокручиваемая область с кнопками разделов
          Expanded(
            child: _buildScrollableSectionButtons(),
          ),
          const SizedBox(height: 20),
          // Кнопка добавления раздела
          _buildAddButton(),
          const SizedBox(height: 20),
          // Кнопка календаря
          _buildCalendarButton(),
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // Создаем прокручиваемый список кнопок разделов
  Widget _buildScrollableSectionButtons() {
    return Scrollbar(
      controller: _sidebarScrollController,
      thumbVisibility: true,
      child: ListView.builder(
        controller: _sidebarScrollController,
        itemCount: _sections.length,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 14, right: 14),
            child: _buildSidebarButton(_sections[index].letter, _sections[index].color, index),
          );
        },
      ),
    );
  }

  Widget _buildSidebarButton(String text, Color color, int index) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: color, width: 2) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    bool isSelected = _selectedIndex == _sections.length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = _sections.length;
        });
      },
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF78909C),
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarButton() {
    bool isSelected = _selectedIndex == _sections.length + 1;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = _sections.length + 1;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            width: isSelected ? 2 : 1,
          ),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.calendar_today,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            size: 22,
          ),
        ),
      ),
    );
  }
}