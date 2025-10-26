import 'package:flutter/material.dart';
import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final todos = await ApiService.fetchTodos();
      setState(() {
        _todos = todos;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _showAddTaskDialog() async {
    final TextEditingController controller = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tugas Baru'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Masukkan judul tugas'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  _addTodo(controller.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addTodo(String title) async {
    try {
      final newTodo = await ApiService.createTodo(title);
      setState(() {
        _todos.add(newTodo);
      });
    } catch (e) {
      _showErrorSnackbar('Gagal menambah tugas: $e');
    }
  }

  Future<void> _toggleTodoStatus(Todo todo) async {
    try {
      final updatedTodo = await ApiService.updateTodoStatus(
        todo.id,
        !todo.isDone,
      );
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _todos[index] = updatedTodo;
        }
      });
    } catch (e) {
      _showErrorSnackbar('Gagal mengupdate tugas: $e');
    }
  }

  Future<void> _deleteTodo(int id) async {
    try {
      await ApiService.deleteTodo(id);
      setState(() {
        _todos.removeWhere((t) => t.id == id);
      });
    } catch (e) {
      _showErrorSnackbar('Gagal menghapus tugas: $e');
    }
  }

  Future<void> _showDeleteConfirmationDialog(int id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Tidak'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); 
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, 
              ),
              onPressed: () {
                _deleteTodo(id); 
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Iya, Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text('Error: $_errorMessage'));
    }
    if (_todos.isEmpty) {
      return const Center(child: Text('Tidak ada tugas. Silakan tambah!'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          child: ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isDone ? TextDecoration.lineThrough : null,
                color: todo.isDone ? Colors.grey : Colors.black,
              ),
            ),
            leading: Checkbox(
              value: todo.isDone,
              onChanged: (bool? value) {
                _toggleTodoStatus(todo);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmationDialog(todo.id); 
              },
            ),
            onTap: () {
              _toggleTodoStatus(todo);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        tooltip: 'Tambah Tugas',
        splashColor: Colors.blue.shade900,
        child: const Icon(Icons.add),
      ),
    );
  }
}
