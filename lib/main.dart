import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Catatanku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TodoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  // 1. Variabel penampung data (State)
  final List<String> _todos = [];
  final TextEditingController _controller = TextEditingController();

  // 2. Fungsi Tambah Tugas
  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todos.add(_controller.text);
        _controller.clear(); // Kosongkan inputan
      });
    }
  }

  // 3. Fungsi Hapus Tugas
  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Catatanku'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Form Input Teks & Tombol
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Tulis tugas baru...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTodo,
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ),
          
          // Daftar Tugas
          Expanded(
            child: _todos.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada tugas. Yuk, tambahkan!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _todos.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          title: Text(_todos[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTodo(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}