import 'package:flutter/material.dart';
import 'filestorage.dart';
import 'dart:convert';

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout'),
      ),
      body: Center(
        child: Text('Workout Page'),
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
                        hintText: 'Title of the workouts',
                      ),
                    ),
                    SizedBox(height: 10),
                    ...List.generate(_controllers.length, (index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Workout ${index + 1}'),
                          TextField(
                            controller: _controllers[index],
                            decoration: InputDecoration(
                              hintText: "Enter a name for Workout ${index + 1}",
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
                      String workoutName = 'Workout ${i + 1}';
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
