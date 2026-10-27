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

// Model kelas Task
class Task {
  String title;
  bool isDone;
  String priority;

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
  
  String _selectedPriority = 'Normal';
  final List<String> _priorities = ['Penting', 'Normal', 'Santai'];

  // Variabel untuk menyimpan status filter yang sedang aktif ('Semua', 'Belum', 'Selesai')
  String _currentFilter = 'Semua';

  // Fungsi Tambah Tugas
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
    }
  }

  // Fungsi Ubah Status Selesai / Belum
  void _toggleTodoStatus(int index) {
    setState(() {
      _todos[index].isDone = !_todos[index].isDone;
    });
  }

  // Fungsi Hapus Tugas
  void _removeTodo(Task task) {
    setState(() {
      _todos.remove(task);
    });
  }

  // Fungsi menentukan warna prioritas
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

    // Logika Filter Tugas berdasarkan tab yang dipilih
    List<Task> filteredTasks = _todos.where((task) {
      if (_currentFilter == 'Belum') return !task.isDone;
      if (_currentFilter == 'Selesai') return task.isDone;
      return true; // 'Semua'
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Catatanku (Update V5)'),
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

          // Tombol Filter Tampilan (Update V5)
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
          
          // Daftar Tugas yang sudah difilter
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada tugas pada kategori ini.',
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
                              // Cari indeks asli tugas di dalam list utama _todos
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
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeTodo(task),
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

  // Widget pendukung untuk tombol filter
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