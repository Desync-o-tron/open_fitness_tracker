import 'package:ollama/ollama.dart';

void main(List<String> args) async {
  final ollama = Ollama();
// Or with a custom base URL:
// final ollama = Ollama(baseUrl: Uri.parse('http://your-ollama-server:11434'));
  final messages = [
    ChatMessage(role: 'user', content: 'Hello, how are you?'),
  ];

  final stream = ollama.chat(
    messages,
    model: 'llama3',
  );

  await for (final chunk in stream) {
    print(chunk.message?.content);
  }
}
