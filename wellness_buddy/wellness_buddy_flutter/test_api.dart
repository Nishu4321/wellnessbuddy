import 'package:wellness_buddy_client/wellness_buddy_client.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';

void main() async {
  final client = Client('http://localhost:8080/');
  try {
    print('Calling chat...');
    final response = await client.chat.sendMessage([], 'Hello Aara');
    print(response.content);
  } catch (e, st) {
    print('Error: $e');
    print(st);
  }
}
