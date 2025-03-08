import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  // Замените на свой API ключ или используйте переменные среды для безопасности
  static const String apiKey = 'ghu_flwC3qPtwVTXX6VkxSLaxqJX3xIU1W2QexTG';
  static const String baseUrl =
      'https://workers-playground-shiny-haze-2f78jjjj.janbolotcode.workers.dev/v1';
}

class ChatGPTService {
  static const String _completionsEndpoint = '/chat/completions';
  static const String _imageGenerationEndpoint = '/images/generations';

  // Полностью переработанный метод для корректной обработки SSE (Server-Sent Events)
  static Stream<String> generateTextStream({
    required String prompt,
    String model = 'gpt-4o',
  }) async* {
    final url = Uri.parse(ApiConfig.baseUrl + _completionsEndpoint);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.apiKey}',
      'Accept': 'text/event-stream', // Важно для SSE
    };

    final body = jsonEncode({
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content':
              'Сиз окуучулар үчүн тексттерди жана тапшырмаларды түзгөн билим берүүчү жардамчысыз.'
        },
        {
          'role': 'system',
          'content':
              'Вы образовательный помощник, который создает тексты и задания для учеников.'
        },
        {'role': 'user', 'content': prompt},
      ],
      'stream': true,
    });

    try {
      // Используем низкоуровневый клиент для потоковой обработки
      final client = http.Client();
      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      request.body = body;

      final response = await client.send(request);

      if (response.statusCode != 200) {
        final errorResponse = await response.stream.bytesToString();
        throw Exception('API Error: ${response.statusCode} - $errorResponse');
      }

      // Собираем полный ответ
      String fullResponse = '';

      // Буфер для накопления неполных строк SSE
      String buffer = '';

      // Обрабатываем поток данных по байтам
      await for (var chunk in response.stream.transform(utf8.decoder)) {
        // Добавляем новый фрагмент к буферу
        buffer += chunk;
        
        // Обрабатываем буфер по строкам SSE
        while (buffer.contains('\n')) {
          final index = buffer.indexOf('\n');
          final line = buffer.substring(0, index);
          buffer = buffer.substring(index + 1);
          
          // Обрабатываем линию SSE
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            
            // Проверяем признак конца потока
            if (data == '[DONE]') {
              print('=== ПОЛНЫЙ ОТВЕТ БЕЗ ПАРСИНГА ===');
              print(fullResponse);
              print('=== КОНЕЦ ПОЛНОГО ОТВЕТА ===');
              break;
            }
            
            try {
              final jsonData = jsonDecode(data);
              final choices = jsonData['choices'] as List<dynamic>;
              
              if (choices.isNotEmpty && choices[0]['delta'] != null) {
                final delta = choices[0]['delta'];
                if (delta.containsKey('content')) {
                  final content = delta['content'] as String;
                  // Добавляем фрагмент к полному ответу
                  fullResponse += content;
                  
                  // Отправляем накопленный ответ
                  yield fullResponse;
                }
              }
            } catch (e) {
              // Только логируем ошибку, но продолжаем обработку
              print('Ошибка при парсинге JSON в потоке: $e');
              print('Проблемная строка: $data');
            }
          }
        }
      }

      // Закрываем клиент
      client.close();
    } catch (e) {
      yield 'Ошибка при получении данных: $e';
      print('Критическая ошибка в потоке SSE: $e');
      rethrow;
    }
  }

  // Генерация образовательного контента
  static Stream<String> generateEducationalContent({
    required String classLevel,
    required String questionsCount,
    required String language,
    String genre = 'сказка',
  }) {
    final String prompt;
    
    if (language == 'Кыргыз') {
      prompt = """
$classLevel-класс окуучулары үчүн кыскача билим берүүчү жомок түзүп бер.

Талаптар:
Жомок кызыктуу жана тарбиялык мааниге ээ болуп, пайдалуу сабак бериш керек.
Узундугу 120 сөздүн тегерегинде болсун.
Жомоктон кийин $questionsCount суроо жана ар бир суроо үчүн 4 варианттуу жооптор болсун.
Суроолор жомоктун мазмуну менен байланыштуу болуп, анын маанисин жакшыраак түшүнүүгө жардам берсин.
Ар бир суроонун туура жообун көрсөт.

Жооптун форматы:
ЖОМОКТУН АТЫ
-------------
Жомоктун тексти

Суроолор:
1. Суроо 1
   A) Вариант A
   B) Вариант B
   C) Вариант C
   D) Вариант D
   Туура жооп: A/B/C/D

2. Суроо 2
   A) Вариант A
   B) Вариант B
   C) Вариант C
   D) Вариант D
   Туура жооп: A/B/C/D

3. Суроо 3
   A) Вариант A
   B) Вариант B
   C) Вариант C
   D) Вариант D
   Туура жооп: A/B/C/D

Жомок балдар үчүн түшүнүктүү, кызыктуу жана тарбиялык мааниге ээ болушу керек.
""";
    } else {
      prompt = """
Создай короткую познавательную сказку на русском языке для учеников $classLevel-го класса.

Требования:
Сказка должна быть увлекательной и обучающей, передавать полезный жизненный урок.
Длина сказки — примерно 120 слов.
После сказки добавь $questionsCount вопроса с четырьмя вариантами ответов.
Вопросы должны быть связаны с содержанием сказки и помогать лучше понять ее смысл.
Укажи правильный ответ для каждого вопроса.

Формат ответа:
ЗАГОЛОВОК СКАЗКИ
-------------
Текст сказки

Вопросы:
1. Вопрос 1
   A) Вариант A
   B) Вариант B
   C) Вариант C
   D) Вариант D
   Правильный ответ: A/B/C/D

2. Вопрос 2
   A) Вариант A
   B) Вариант B
   C) Вариант C
   D) Вариант D
   Правильный ответ: A/B/C/D

3. Вопрос 3
   A) Вариант A
   B) Вариант B
   C) Вариант C
   D) Вариант D
   Правильный ответ: A/B/C/D

Сделай сказку интересной, легкой для понимания и полезной для детей.
""";
    }

    return generateTextStream(prompt: prompt);
  }

  static Future<String> generateImage({
    required String title,
    required String content,
    String language = 'Кыргыз',
  }) async {
    final url = Uri.parse(ApiConfig.baseUrl + _imageGenerationEndpoint);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${ApiConfig.apiKey}',
    };

    final description =
        content.length > 300 ? content.substring(0, 300) : content;

    final prompt = """
    Создай иллюстрацию к детской сказке с названием "$title". 
    Содержание сказки: "$description".
    
    Изображение должно быть ярким, красочным, выполненным в стиле детской иллюстрации.
    Изображение должно быть подходящим для детей ${language == 'Кыргыз' ? 'в Кыргызстане' : 'в России'}.
    """;

    final body = jsonEncode({
      'prompt': prompt,
      'n': 1,
      'size': '1024x1024',
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data'][0]['url'];
    } catch (e) {
      throw Exception('Ошибка при генерации изображения: $e');
    }
  }

  // Улучшенный метод для парсинга текстового ответа
  static Map<String, dynamic> parseContentText(
      String text, String questionsCount) {
    try {
      final expectedQuestionCount = int.tryParse(questionsCount) ?? 3;
      
      // Выводим полный непарсированный ответ для проверки
      print('=== ТЕКСТ ПЕРЕД НАЧАЛОМ ПАРСИНГА ===');
      print(text);
      print('=== КОНЕЦ ИСХОДНОГО ТЕКСТА ===');
      
      // Разделяем текст на строки, сохраняя переносы строк
      final List<String> lines = text.split('\n');
      
      // Ищем заголовок (первая непустая строка)
      String title = 'Сказка';
      for (var line in lines) {
        if (line.trim().isNotEmpty) {
          title = line.trim();
          break;
        }
      }
      
      // Находим начало блока с вопросами
      int questionsStartIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].trim().contains('Вопросы:') || 
            lines[i].trim().contains('Суроолор:')) {
          questionsStartIndex = i;
          break;
        }
      }
      
      // Если блок с вопросами не найден, используем заданную структуру
      if (questionsStartIndex == -1) {
        print('Не удалось найти блок с вопросами в тексте');
        return _getDefaultContent();
      }
      
      // Находим индекс, с которого начинается текст сказки (после заголовка и разделителя)
      int contentStartIndex = 0;
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('---') || 
            (i > 0 && lines[i].trim().isEmpty && lines[i-1].trim() == title)) {
          contentStartIndex = i + 1;
          break;
        }
      }
      
      // Извлекаем текст сказки, сохраняя форматирование
      final content = lines
          .sublist(contentStartIndex, questionsStartIndex)
          .join('\n')
          .trim();
      
      print('=== ИЗВЛЕЧЕННЫЙ ТЕКСТ СКАЗКИ ===');
      print(content);
      print('=== КОНЕЦ ТЕКСТА СКАЗКИ ===');
      
      // Парсим вопросы и варианты ответов
      final List<Map<String, dynamic>> questions = [];
      int currentLine = questionsStartIndex + 1;
      
      while (currentLine < lines.length && questions.length < expectedQuestionCount) {
        // Пропускаем пустые строки
        if (lines[currentLine].trim().isEmpty) {
          currentLine++;
          continue;
        }
        
        // Проверяем, является ли строка началом вопроса
        final RegExp questionPattern = RegExp(r'^\s*\d+\.\s*(.+)');
        final questionMatch = questionPattern.firstMatch(lines[currentLine]);
        
        if (questionMatch != null) {
          final String questionText = questionMatch.group(1)!.trim();
          final List<String> options = [];
          int optionLine = currentLine + 1;
          
          print('Найден вопрос: $questionText');
          
          // Собираем варианты ответов
          while (optionLine < lines.length && options.length < 4) {
            final String line = lines[optionLine].trim();
            final RegExp optionPattern = RegExp(r'^\s*([A-D])\)\s*(.+)');
            final optionMatch = optionPattern.firstMatch(line);
            
            if (optionMatch != null) {
              final String option = optionMatch.group(2)!.trim();
              options.add(option);
              print('  Вариант ${optionMatch.group(1)}: $option');
            }
            
            optionLine++;
          }
          
          // Дополняем варианты ответов, если их меньше 4
          while (options.length < 4) {
            options.add('Вариант ${String.fromCharCode(65 + options.length)}');
          }
          
          // Ищем указание правильного ответа
          int correctIndex = 0;
          for (int i = optionLine; i < lines.length && i < optionLine + 3; i++) {
            if (i >= lines.length) break;
            
            final String line = lines[i].trim();
            final RegExp correctPattern = RegExp(r'Правильный ответ:\s*([A-D])|Туура жооп:\s*([A-D])');
            final correctMatch = correctPattern.firstMatch(line);
            
            if (correctMatch != null) {
              final String correctOption = (correctMatch.group(1) ?? correctMatch.group(2))!;
              correctIndex = 'ABCD'.indexOf(correctOption);
              print('  Правильный ответ: $correctOption (индекс: $correctIndex)');
              break;
            }
          }
          
          // Добавляем вопрос в список
          questions.add({
            'question': questionText,
            'options': options,
            'correctIndex': correctIndex
          });
          
          // Переходим к следующему вопросу
          currentLine = optionLine + 3;
        } else {
          currentLine++;
        }
      }
      
      // Если вопросов меньше, чем ожидалось, добавляем стандартные
      while (questions.length < expectedQuestionCount) {
        questions.add({
          'question': 'Дополнительный вопрос',
          'options': ['Вариант A', 'Вариант B', 'Вариант C', 'Вариант D'],
          'correctIndex': 0
        });
      }
      
      // Возвращаем структурированный результат
      return {'title': title, 'content': content, 'questions': questions};
    } catch (e) {
      print('Ошибка при парсинге текста: $e');
      print('Текст, вызвавший ошибку: $text');
      return _getDefaultContent();
    }
  }

  // Метод для получения контента по умолчанию
  static Map<String, dynamic> _getDefaultContent() {
    return {
      'title': 'Сказка',
      'content': 'Не удалось загрузить текст',
      'questions': [
        {
          'question': 'Что произошло?',
          'options': ['Ошибка', 'Попробовать снова', 'Выйти', 'Помощь'],
          'correctIndex': 0
        }
      ]
    };
  }
}