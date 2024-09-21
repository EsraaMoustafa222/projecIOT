import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String apiUrl = 'https://api.groq.com/openai/v1/chat/completions'; // Replace with the Groq API URL
  final String apiKey = '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'; // Replace with your actual Groq API key

  Future<String> sendMessage(String userMessage) async {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': 'mixtral-8x7b-32768',
      'messages': [
        {
          'role': 'user',
          'content': userMessage,
        }
      ],
      // Additional parameters can be added here if required by the API
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('choices') && data['choices'].isNotEmpty) {
          final generatedText = data['choices'][0]['message']['content'];
          return generatedText.trim();
        } else {
          return 'No response generated';
        }
      } else {
        return 'Error: ${response.statusCode} ${response.body}';
      }
    } catch (e) {
      return 'Exception: $e';
    }
  }
}
