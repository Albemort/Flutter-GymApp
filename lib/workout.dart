import 'package:flutter/material.dart';
import 'filestorage.dart';
import 'dart:convert';

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {

  Future<Map<String, dynamic>> _readDataFromFile() async {
    return await FileStorage.readFile("workouts.txt");
  }

    Future<void> _refreshPage() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workouts'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshPage,
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
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _readDataFromFile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Map<String, dynamic> data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  String day = data.keys.elementAt(index);
                  List<Map<String, dynamic>> workouts = List<Map<String, dynamic>>.from(data[day]);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          day,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: workouts.map((workout) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: workout.entries.map((entry) {
                              return ListTile(
                                title: Text(entry.key),
                                subtitle: Text(entry.value),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<void> _displayTextInputDialog(BuildContext context) async {
  List<TextEditingController> _controllers = [];
  int maxFields = 10;

  // Add 1 initial field
  _controllers.add(TextEditingController());

  TextEditingController _titleController = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Create workouts'),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                      ),
                    ),
                    SizedBox(height: 10),
                    ...List.generate(_controllers.length, (index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Exercise ${index + 1}'),
                          TextField(
                            controller: _controllers[index],
                            decoration: InputDecoration(
                              hintText: "Enter a name for the exercise ${index + 1}",
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Add'),
                onPressed: () {
                  if (_controllers.length < maxFields) {
                    setState(() {
                      _controllers.add(TextEditingController());
                    });
                  }
                },
              ),
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Map<String, dynamic> workoutWhole = {};
                  String workoutTitle = _titleController.text; 
                  Map<String, dynamic> myWorkouts = {};

                  for (int i = 0; i < _controllers.length; i++) {
                      String workoutName = 'Exercise ${i + 1}';
                      String workoutText = _controllers[i].text;
                      print('$workoutName: $workoutText');

                      // Assign workoutText to the workoutName key in the inner map
                      workoutWhole[workoutName] = workoutText;
                  }

                  // Check if the workoutTitle already exists
                  if (myWorkouts.containsKey(workoutTitle)) {
                      // Append the workoutWhole map to the existing list of workouts
                      myWorkouts[workoutTitle].add(workoutWhole);
                  } else {
                      // Create a new list and add the workoutWhole map
                      myWorkouts[workoutTitle] = [workoutWhole];
                  }

                  print(myWorkouts);

                  // Convert myWorkouts map to JSON format
                  String jsonContent = json.encode(myWorkouts);

                  // Write myWorkouts to file
                  FileStorage.writeCounter(jsonContent, "workouts.txt");

                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    },
  );
}
