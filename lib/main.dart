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

// Model kelas diperbarui dengan atribut priority (Prioritas)
class Task {
  String title;
  bool isDone;
  String priority; // 'Penting', 'Normal', atau 'Santai'

  Task({
    required this.title,
    this.isDone = false,
    this.priority = 'Normal',
  });
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<Task> _todos = [];
  final TextEditingController _controller = TextEditingController();
  
  // Variabel untuk menyimpan pilihan prioritas saat membuat tugas baru
  String _selectedPriority = 'Normal';
  final List<String> _priorities = ['Penting', 'Normal', 'Santai'];

  // Fungsi Tambah Tugas dengan Prioritas
  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todos.add(Task(
          title: _controller.text,
          priority: _selectedPriority,
        ));
        _controller.clear();
        _selectedPriority = 'Normal'; // Reset ke default
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

  // Fungsi untuk menentukan warna berdasarkan prioritas
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Penting':
        return Colors.red;
      case 'Normal':
        return Colors.blue;
      case 'Santai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalTask = _todos.length;
    int completedTask = _todos.where((task) => task.isDone).length;
    int pendingTask = totalTask - completedTask;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Catatanku (Update V4)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Widget Ringkasan Statistik Tugas
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

          // Form Input Teks, Pilihan Prioritas, & Tombol (Update V4)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Tulis tugas baru...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Prioritas: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    // Dropdown untuk memilih prioritas
                    DropdownButton<String>(
                      value: _selectedPriority,
                      items: _priorities.map((String priority) {
                        return DropdownMenuItem<String>(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriority = newValue;
                          });
                        }
                      },
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _addTodo,
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Daftar Tugas dengan Indikator Warna Prioritas
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
                          // Badge / Chip kecil untuk menampilkan tingkat prioritas di sisi kanan
                          subtitle: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(task.priority).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  task.priority,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getPriorityColor(task.priority),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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