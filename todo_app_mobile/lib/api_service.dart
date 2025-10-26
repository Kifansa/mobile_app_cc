import 'dart:convert';
import 'package:http/http.dart' as http;

class Todo {
  final int id;
  final String title;
  final bool isDone;

  Todo({required this.id, required this.title, required this.isDone});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isDone: json['is_done'] ?? false,
    );
  }
}

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/';

  static final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  static Future<List<Todo>> fetchTodos() async {
    final response = await http.get(Uri.parse('${_baseUrl}todos'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Todo> todos = body
          .map((dynamic item) => Todo.fromJson(item))
          .toList();
      return todos;
    } else {
      throw Exception('Gagal memuat data to-do');
    }
  }

  static Future<Todo> createTodo(String title) async {
    final response = await http.post(
      Uri.parse('${_baseUrl}todos'),
      headers: _headers,
      body: jsonEncode(<String, String>{'title': title}),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah data to-do');
    }
  }

  static Future<Todo> updateTodoStatus(int id, bool isDone) async {
    final response = await http.put(
      Uri.parse('${_baseUrl}todos/$id'),
      headers: _headers,
      body: jsonEncode(<String, bool>{'is_done': isDone}),
    );

    if (response.statusCode == 200) {
      return Todo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengupdate status to-do');
    }
  }

  static Future<void> deleteTodo(int id) async {
    final response = await http.delete(Uri.parse('${_baseUrl}todos/$id'));

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Gagal menghapus to-do');
    }
  }
}
