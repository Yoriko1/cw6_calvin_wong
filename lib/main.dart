import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Task Model
class Task {
  String id;
  String name;
  bool isCompleted;
  List<Task>? subTasks;

  Task({required this.id, required this.name, this.isCompleted = false, this.subTasks = const []});

  factory Task.fromMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      name: data['name'],
      isCompleted: data['isCompleted'] ?? false,
      subTasks: (data['subTasks'] as List<dynamic>?)
          ?.map((subTask) => Task.fromMap(subTask as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'subTasks': subTasks?.map((task) => task.toMap()).toList() ?? [],
    };
  }
}

// Main App
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

// LoginScreen for Authentication
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskListScreen()),
      );
    } catch (e) {
      print("Login failed: $e"); // Print the error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed')));
    }
  }

  Future<void> _signup() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TaskListScreen()),
      );
    } catch (e) {
      print("Login failed: $e"); // Print the error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign Up failed')));
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text('Login')),
            ElevatedButton(onPressed: _signup, child: Text('Sign Up')),
          ],
        ),
      ),
    );
  }
}

// TaskListScreen to manage tasks
class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _taskController = TextEditingController();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final snapshot = await _firestore.collection('tasks').doc(currentUser.uid).get();
      if (snapshot.exists) {
        List<dynamic> taskData = snapshot.data()?['tasks'] ?? [];
        setState(() {
          tasks = taskData.map((task) => Task.fromMap(task)).toList();
        });
      }
    }
  }

Future<void> _addTask() async {
  final currentUser = _auth.currentUser;

  // Check if user is logged in
  if (currentUser != null && _taskController.text.isNotEmpty) {
    try {
      // Reference to the user's document
      DocumentReference userDocRef = _firestore.collection('tasks').doc(currentUser.uid);
      
      // Get the document
      DocumentSnapshot docSnapshot = await userDocRef.get();

      // Check if the document exists
      if (!docSnapshot.exists) {
        // If the document doesn't exist, create it with an empty 'tasks' field
        await userDocRef.set({
          'tasks': [],  // Initialize the 'tasks' array if the document doesn't exist
        });
      }

      // Now add the new task to the user's tasks list
      Task newTask = Task(id: DateTime.now().toString(), name: _taskController.text);
      await userDocRef.update({
        'tasks': FieldValue.arrayUnion([newTask.toMap()]),  // Add the task to the array
      });

      _taskController.clear();
      _loadTasks();  // Reload tasks after adding
    } catch (e) {
      print("Error adding task: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add task: $e')));
    }
  }
}


Future<void> _toggleTaskCompletion(Task task) async {
  final currentUser = _auth.currentUser;
  
  if (currentUser != null) {
    try {
      // Get reference to the user's task document
      DocumentReference userDocRef = _firestore.collection('tasks').doc(currentUser.uid);
      
      // Fetch the current tasks array from Firestore
      DocumentSnapshot docSnapshot = await userDocRef.get();
      if (docSnapshot.exists) {
        // Safely cast the data to a Map<String, dynamic>
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

        // Get the list of tasks
        List<dynamic> tasksData = data['tasks'] ?? [];
        
        // Find the task to update based on the task's ID
        int taskIndex = tasksData.indexWhere((t) => t['id'] == task.id);
        
        if (taskIndex != -1) {
          // Toggle the task's completion status
          tasksData[taskIndex]['isCompleted'] = !tasksData[taskIndex]['isCompleted'];
          
          // Update the task in Firestore
          await userDocRef.update({
            'tasks': tasksData,  // Update the tasks array
          });

          // Reload tasks after update
          _loadTasks();
        }
      }
    } catch (e) {
      print("Error updating task: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
    }
  }
}



  Future<void> _deleteTask(Task task) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('tasks').doc(currentUser.uid).update({
        'tasks': FieldValue.arrayRemove([task.toMap()])
      });
      _loadTasks();  // Reload tasks after deleting
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(labelText: 'Enter task name'),
            ),
            ElevatedButton(onPressed: _addTask, child: Text('Add Task')),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    title: Text(task.name),
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) {
                        _toggleTaskCompletion(task);
                      },
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteTask(task),
                    ),
                    subtitle: Column(
                      children: task.subTasks?.map((subTask) {
                        return ListTile(
                          title: Text(subTask.name),
                          leading: Checkbox(
                            value: subTask.isCompleted,
                            onChanged: (value) {
                              _toggleTaskCompletion(subTask);
                            },
                          ),
                        );
                      }).toList() ?? [],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
