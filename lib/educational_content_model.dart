class Question {
  final String question;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.question, 
    required this.options, 
    required this.correctIndex
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'] ?? 'Вопрос',
      options: List<String>.from(json['options'] ?? ['Вариант A', 'Вариант B', 'Вариант C', 'Вариант D']),
      correctIndex: json['correctIndex'] is int 
        ? json['correctIndex'] 
        : int.tryParse(json['correctIndex'].toString()) ?? 0
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'options': options,
    'correctIndex': correctIndex
  };
}

class EducationalContent {
  final String title;
  final String content;
  final List<Question> questions;

  EducationalContent({
    required this.title, 
    required this.content, 
    required this.questions
  });

  factory EducationalContent.fromJson(Map<String, dynamic> json) {
    return EducationalContent(
      title: json['title'] ?? 'Сказка',
      content: json['content'] ?? json['text'] ?? 'Текст отсутствует',
      questions: json['questions'] != null 
        ? (json['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList()
        : [
            Question(
              question: 'О чем эта сказка?', 
              options: ['О дружбе', 'О трудолюбии', 'О животных', 'О приключениях'],
              correctIndex: 0
            )
          ]
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'questions': questions.map((q) => q.toJson()).toList()
  };
}