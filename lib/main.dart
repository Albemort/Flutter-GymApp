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

class MyHomePage extends StatelessWidget {
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
      body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: 10, // You can set it according to your workouts list length
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    // Implement logic to show popup for custom weight and sets
                    FileStorage.readKeys("workouts.txt");
                  },
                  child: Card(
                    child: Center(
                      child: Text('Workout ${index + 1}'),
                    ),
                  ),
                );
              },
            ),
        backgroundColor: Color.fromARGB(255, 216, 216, 216),
    );
  }
}



