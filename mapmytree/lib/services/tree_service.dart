import 'dart:convert';
import 'package:http/http.dart' as http;

class TreeService {
  static Future<List> fetchTrees() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/trees') // replace IP
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load trees');
    }
  }
}