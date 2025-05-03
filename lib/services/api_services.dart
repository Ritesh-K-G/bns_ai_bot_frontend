import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://your-backend-url/chat';

  static Future<String> sendMessage(String message) async {
    // final response = await http.post(
    //   Uri.parse(baseUrl),
    //   headers: {'Content-Type': 'application/json'},
    //   body: json.encode({'message': message}),
    // );
    // final data = json.decode(response.body);
    // return data['reply'];
    return "Hello";
  }
}

