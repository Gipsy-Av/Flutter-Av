import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

// Model kelas Task yang diperbarui agar bisa diubah ke format JSON (untuk disimpan)
class Task {
  String title;
  bool isDone;
  String priority;

  Task({
    required this.title,
    this.isDone = false,
    this.priority = 'Normal',
  });

  // Mengubah objek Task menjadi Map (JSON)
  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'priority': priority,
      };

  // Membuat objek Task dari Map (JSON)
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        isDone: json['isDone'],
        priority: json['priority'],
      );
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  List<Task> _todos = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _selectedPriority = 'Normal';
  final List<String> _priorities = ['Penting', 'Normal', 'Santai'];
  String _currentFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Muat data tersimpan saat aplikasi pertama kali dibuka
  }

  // --- FITUR PENYIMPANAN LOKAL (SharedPreferences) ---
  
  // Simpan daftar tugas ke memori HP
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> taskListString = _todos.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList('saved_tasks', taskListString);
  }

  // Ambil daftar tugas dari memori HP
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? taskListString = prefs.getStringList('saved_tasks');
    if (taskListString != null) {
      setState(() {
        _todos = taskListString.map((item) => Task.fromJson(jsonDecode(item))).toList();
      });
    }
  }

  // --- AKSI DATA ---

  void _addTodo() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _todos.add(Task(
          title: _controller.text,
          priority: _selectedPriority,
        ));
        _controller.clear();
        _selectedPriority = 'Normal';
      });
      _saveTasks(); // Simpan perubahan
    }
  }

  void _toggleTodoStatus(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
    _saveTasks(); // Simpan perubahan
  }

  // Dialog Konfirmasi Hapus (Update V7)
  void _confirmDelete(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Tugas'),
          content: Text('Yakin ingin menghapus "${task.title}"?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _todos.remove(task);
                });
                _saveTasks(); // Simpan perubahan
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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

    List<Task> filteredTasks = _todos.where((task) {
      bool matchesStatus = true;
      if (_currentFilter == 'Belum') matchesStatus = !task.isDone;
      if (_currentFilter == 'Selesai') matchesStatus = task.isDone;

      bool matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesStatus && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Catatanku (Update V7)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Widget Statistik
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

          // Form Input Tugas & Prioritas
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

          // Kotak Pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari tugas...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Filter Tampilan
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFilterButton('Semua'),
                const SizedBox(width: 8),
                _buildFilterButton('Belum'),
                const SizedBox(width: 8),
                _buildFilterButton('Selesai'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Daftar Tugas
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada tugas yang ditemukan.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: Checkbox(
                            value: task.isDone,
                            onChanged: (bool? value) {
                              int originalIndex = _todos.indexOf(task);
                              _toggleTodoStatus(originalIndex);
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
                          // Tombol Hapus memicu AlertDialog konfirmasi
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(task),
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

  Widget _buildFilterButton(String filterName) {
    bool isSelected = _currentFilter == filterName;
    return ChoiceChip(
      label: Text(filterName),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _currentFilter = filterName;
        });
      },
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