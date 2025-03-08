import 'package:flutter/material.dart';

class WorkPage extends StatelessWidget {
  final VoidCallback onAddTask;

  const WorkPage({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: _buildTaskList(),
        ),
        _buildAddTaskButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ТАПШЫРМАЛАРЫМ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Жумуш',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final List<WorkTask> tasks = [
      WorkTask(
        title: 'Класс сабактары проекттерин иштеп чыгуу',
        date: DateTime.now(),
        time: '10:00',
        isNew: true,
      ),
      WorkTask(
        title: 'Ата-энелер менен жыйналышына катышуу',
        date: DateTime.now(),
        time: '14:00',
        isNew: true,
      ),
      WorkTask(
        title: 'Класстык жумуштан текшерүү',
        date: DateTime.now(),
        time: '16:00',
        isNew: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskItem(task);
      },
    );
  }

  Widget _buildTaskItem(WorkTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.check_box_outline_blank, color: Colors.grey),
        title: Text(
          task.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${task.date.day}.${task.date.month}.${task.date.year} · ${task.time} · Жумуш',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: task.isNew
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Жаңы',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildAddTaskButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onAddTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C313A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Жаңы тапшырма кошуу',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// Класс для задач
class WorkTask {
  final String title;
  final DateTime date;
  final String time;
  final bool isNew;

  WorkTask({
    required this.title,
    required this.date,
    required this.time,
    required this.isNew,
  });
}