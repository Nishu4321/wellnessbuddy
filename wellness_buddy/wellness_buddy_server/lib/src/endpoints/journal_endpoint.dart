import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:wellness_buddy_server/src/generated/protocol.dart';

class JournalEndpoint extends Endpoint {
  static const _groqApiUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  Future<JournalAnalysis> analyzeJournal(Session session, String text) async {
    final apiKey =
        session.serverpod.getPassword('groq_api_key') ?? 'DUMMY_KEY';

    if (apiKey == 'DUMMY_KEY' || apiKey == 'YOUR_GROQ_API_KEY_HERE') {
      throw Exception(
          'Groq API Key Missing: Please add your key to passwords.yaml under groq_api_key and restart the server. Get a free key at console.groq.com');
    }

    const systemPrompt =
        'You are a stress analysis AI. You ONLY respond with valid JSON. Never add explanation outside the JSON.';

    final userPrompt = '''
Analyze the following student journal entry and identify hidden stress triggers.

Return ONLY a valid JSON object in this exact format — no markdown, no extra text:
{
  "triggers": [
    {
      "trigger": "brief trigger name",
      "category": "one of: Exam Pressure, Academic Performance, Mock Test Scores, Time Management, Family Expectations, Peer Comparison, Sleep Problems, Health Issues, Future Uncertainty, Relationship Issues, Financial Concerns",
      "severity": <integer 1-10>,
      "evidence": "exact quote or close paraphrase from the journal",
      "explanation": "why this is a stress trigger for this student"
    }
  ]
}

Rules:
- Do not invent triggers. Only use what is in the journal.
- severity 1-3 = mild, 4-6 = moderate, 7-10 = severe.
- Return an empty triggers array [] if no triggers found.

Journal Entry:
$text
''';

    try {
      final response = await http
          .post(
            Uri.parse(_groqApiUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': systemPrompt},
                {'role': 'user', 'content': userPrompt},
              ],
              'temperature': 0.3,
              'max_tokens': 1024,
              'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        session.log(
            'Groq API error ${response.statusCode}: ${response.body}',
            level: LogLevel.error);
        throw Exception(
            'AI service returned error ${response.statusCode}. Please try again.');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          data['choices']?[0]?['message']?['content'] as String? ?? '{}';

      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final triggersList = decoded['triggers'] as List<dynamic>? ?? [];

      final triggers = triggersList.map((t) {
        final map = t as Map<String, dynamic>;
        return StressTrigger(
          trigger: map['trigger']?.toString() ?? 'Unknown',
          category: map['category']?.toString() ?? 'Exam Pressure',
          severity: (map['severity'] is int)
              ? map['severity'] as int
              : int.tryParse(map['severity']?.toString() ?? '5') ?? 5,
          evidence: map['evidence']?.toString() ?? '',
          explanation: map['explanation']?.toString() ?? '',
        );
      }).toList();

      return JournalAnalysis(triggers: triggers);
    } catch (e) {
      session.log('Journal Analysis Error: $e', level: LogLevel.error);
      rethrow;
    }
  }
}
