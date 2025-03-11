import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'educational_content_model.dart';

class EducationalContentService {
  // Метод для генерации образовательного контента
  static Future<EducationalContent> generateContent({
    required String classLevel,
    required String questionsCount,
    required String language,
    String genre = 'сказка',
  }) async {
    final prompt = _buildContentPrompt(
        classLevel: classLevel,
        questionsCount: questionsCount,
        language: language,
        genre: genre);

    final response = await _sendChatGPTRequest(prompt);
    return _parseEducationalContent(response);
  }

  // Приватный метод для формирования промпта
  static String _buildContentPrompt({
    required String classLevel,
    required String questionsCount,
    required String language,
    required String genre,
  }) {
    return """
Создай короткую ${language == 'Кыргыз' ? 'сказку на кыргызском языке' : 'сказку на русском языке'} для учеников $classLevel-класса.
  
Требования:
1. Сказка должна быть образовательной, интересной и иметь мораль.
2. Длина сказки - примерно 120 слов.
3. После сказки должно быть $questionsCount вопросов с 4 вариантами ответа.
4. Каждый вопрос должен быть по содержанию сказки.
5. У каждого вопроса должен быть один правильный вариант ответа.
  
ВАЖНО: Ответ должен быть строго в формате JSON с точными полями.
""";
  }

  // Отправка запроса к ChatGPT
  static Future<String> _sendChatGPTRequest(String prompt) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.completionsEndpoint}');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.apiKey}',
    };

    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content':
              'Ты образовательный помощник, который создает тексты и задания для школьников.'
        },
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw Exception(
            'Ошибка API: ${response.statusCode} - ${response.body}');
      }

      final responseData = jsonDecode(response.body);
      return responseData['choices'][0]['message']['content'];
    } catch (e) {
      debugPrint('Ошибка при запросе: $e');
      rethrow;
    }
  }

  // Парсинг JSON с расширенной обработкой ошибок
  static EducationalContent _parseEducationalContent(String jsonData) {
    try {
      // Подготовка JSON
      jsonData = _preprocessJson(jsonData);

      // Декодирование JSON
      final Map<String, dynamic> jsonMap = jsonDecode(jsonData);

      // Создание модели
      return EducationalContent.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Ошибка парсинга: $e');

      // Возвращаем резервный контент
      return EducationalContent(
          title: 'Ошибка генерации',
          content: 'Не удалось создать контент. Попробуйте еще раз.',
          questions: [
            Question(
                question: 'Что произошло?',
                options: [
                  'Ошибка',
                  'Попробовать снова',
                  'Связаться с поддержкой',
                  'Выйти'
                ],
                correctIndex: 1)
          ]);
    }
  }

  // Предобработка JSON перед декодированием
  static String _preprocessJson(String jsonData) {
    // Удаление лишних пробелов и символов
    jsonData = jsonData.trim();

    // Поиск JSON-блока
    final startIndex = jsonData.indexOf('{');
    final endIndex = jsonData.lastIndexOf('}');

    if (startIndex == -1 || endIndex == -1) {
      throw const FormatException('Не найден корректный JSON');
    }

    jsonData = jsonData.substring(startIndex, endIndex + 1);

    // Замена одинарных кавычек на двойные
    jsonData = jsonData.replaceAll("'", '"');

    // Экранирование специальных символов
    jsonData = jsonData.replaceAll('\\"', '"');
    jsonData = jsonData.replaceAll('\\n', ' ');

    return jsonData;
  }

  // Генерация изображения
  static Future<String> generateImage({
    required String title,
    required String content,
    String language = 'Русский',
  }) async {
    final url =
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.imageGenerationEndpoint}');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.apiKey}',
    };

    final description =
        content.length > 300 ? content.substring(0, 300) : content;

    final prompt = """
    Создай иллюстрацию к детской сказке с названием "$title". 
    Содержание сказки: "$description".
    
    Изображение должно содержать элементы, персонажи и животные сказки и передавать ее смысл.
    Изображение должно быть ярким, красочным, выполненным в стиле детской иллюстрации.
    Изображение должно быть подходящим для детей """;

    final body = jsonEncode({
      'model': 'dall-e-3',
      'prompt': prompt,
      'n': 1,
      'size': '1024x1024',
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        print('response.body ${response.body}');
        throw Exception(
            'Ошибка генерации: ${response.statusCode} - ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data'][0]['url'];
    } catch (e) {
      debugPrint('Ошибка при генерации изображения: $e');
      return 'assets/images/fallback_story.png'; // Путь к резервному изображению
    }
  }
}
