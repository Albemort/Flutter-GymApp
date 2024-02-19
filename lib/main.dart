import 'package:flutter/material.dart';
import 'workout.dart';
import 'filestorage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      routes: {
        '/home': (context) => MyHomePage(),
        '/workouts': (context) => WorkoutPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<String>> keysFuture;

  @override
  void initState() {
    super.initState();
    keysFuture = _readKeysFromFile();
  }

  Future<List<String>> _readKeysFromFile() async {
    return await FileStorage.readKeys("workouts.txt");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Journal'),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: () {
              // Handle favorite icon tap
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Handle search icon tap
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options icon tap
            },
          ),
        ],
        leading: PopupMenuButton(
          icon: Icon(Icons.menu),
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              child: Text("Journal"),
              value: 1,
            ),
            PopupMenuItem(
              child: Text("Workouts"),
              value: 2,
            ),
          ],
          onSelected: (value) {
            // Handle menu item selection here.
            switch (value) {
              case 1:
                // Handle menu item 1
                Navigator.pushNamed(context, '/home');
                break;
              case 2:
                // Handle menu item 3
                Navigator.pushNamed(context, '/workouts');
                break;
            }
          },
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: keysFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<String> keys = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: keys.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // Implement logic to show popup for custom weight and sets
                  },
                  child: Card(
                    child: Center(
                      child: Text('Workout ${index + 1}'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      backgroundColor: Color.fromARGB(255, 216, 216, 216),
    );
  }
}


