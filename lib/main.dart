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

// Model kelas untuk menyimpan data tugas beserta status selesai/belum
class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Task> _todos = [];
  final TextEditingController _controller = TextEditingController();

  // Fungsi Tambah Tugas
  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todos.add(Task(title: _controller.text));
        _controller.clear();
      });
    }
  }

  // Fungsi Ubah Status Selesai / Belum
  void _toggleTodoStatus(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  // Fungsi Hapus Tugas
  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Menghitung jumlah tugas menggunakan fungsi filter Dart
    int totalTask = _todos.length;
    int completedTask = _todos.where((task) => task.isDone).length;
    int pendingTask = totalTask - completedTask;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Catatanku (Update V3)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Widget Ringkasan Statistik Tugas (Update V3)
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', totalTask.toString(), Colors.blue),
                _buildStatCard('Belum', pendingTask.toString(), Colors.orange),
                _buildStatCard('Selesai', completedTask.toString(), Colors.green),
              ],
            ),
          ),

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
          
          // Daftar Tugas dengan Checkbox
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
                      final task = _todos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (bool? value) {
                              _toggleTodoStatus(index);
                            },
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              color: task.isDone ? Colors.grey : Colors.black,
                            ),
                          ),
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

  // Widget pendukung untuk mempercantik kartu statistik
  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }
}