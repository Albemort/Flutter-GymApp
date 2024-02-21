import 'package:flutter/material.dart';
import 'workout.dart';
import 'filestorage.dart';
import 'history.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
        '/history': (context) => HistoryPage(),
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

    Future<void> _refreshData() async {
    setState(() {
      keysFuture = _readKeysFromFile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
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
            PopupMenuItem(
              child: Text("History"),
              value: 3,
            ),
          ],
          onSelected: (value) {
            // Handle menu item selection here.
            switch (value) {
              case 1:
                // Handle menu item 1
                _refreshData();
                break;
              case 2:
                // Handle menu item 2
                Navigator.pushNamed(context, '/workouts');
                break;
              case 3:
                // Handle menu item 2
                Navigator.pushNamed(context, '/history');
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
            if(keys.length == 0) {
              return Scaffold(
                body: Center(
                  child: Text('No existing workouts yet, create one from the workouts page!'),
                ),
              );
            } else {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: keys.length,
                itemBuilder: (context, index) {
                  final key = keys[index];
                  return InkWell(
                    onTap: () {
                      selectWorkoutDialog(context, key);
                    },
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(child: Text(key)),
                          IconButton(
                            onPressed: () {
                              _deleteWorkoutDialog(context, key);
                            },
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
      backgroundColor: Color.fromARGB(255, 216, 216, 216),
    );
  }
}

Future<void> _deleteWorkoutDialog(context, String key) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Removing Workout'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to delete this workout?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              FileStorage.removeElement(key, "workouts.txt");
              Navigator.pop(context);
            },
          ),
        ],
      );
    }
  );
}

Future<void> selectWorkoutDialog(context, String key) async {
  Future<Map<String, dynamic>> _readDataFromFile() async {
    // Replace this with your actual file reading logic
    return await FileStorage.readFile("workouts.txt");
  }
  return showDialog<void> (
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select an exercise'),
        content: FutureBuilder<Map<String, dynamic>>(
          future: _readDataFromFile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              Map<String, dynamic> data = snapshot.data!;
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: data[key].length,
                  itemBuilder: (context, index) {
                    List<Map<String, dynamic>> workouts =
                        List<Map<String, dynamic>>.from(data[key]);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                        ),
                        Column(
                          children: workouts.map((workout) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: workout.entries.map((entry) {
                                //print(entry.value);
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: TextButton(
                                    onPressed: () {
                                      // Trigger your dialog here
                                      weightInputDialog(context, entry.value);
                                    },
                                    child: Text(entry.value),
                                  ),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              );
            }
          },
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Back'),
          ),
        ],
      );
    }
  );
}

Future<void> weightInputDialog(BuildContext context, dynamic exercise) async {
  double weight = 0.0;
  int sets = 1;
  int reps = 1;

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Enter Weight, Sets, and Reps Done'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                  ),
                  onChanged: (value) {
                    setState(() {
                      weight = double.tryParse(value) ?? 0.0;
                    });
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          sets = (sets < 10) ? sets + 1 : sets;
                        });
                      },
                      icon: Icon(Icons.add),
                    ),
                    Text('Sets: $sets'),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          sets = (sets > 1) ? sets - 1 : sets;
                        });
                      },
                      icon: Icon(Icons.remove),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          reps = (reps < 20) ? reps + 1 : reps;
                        });
                      },
                      icon: Icon(Icons.add),
                    ),
                    Text('Reps: $reps'),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          reps = (reps > 1) ? reps - 1 : reps;
                        });
                      },
                      icon: Icon(Icons.remove),
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Handle saving the weight, sets, and reps
                  print('Exercise: $exercise, Weight: $weight, Sets: $sets, Reps: $reps');
                  sendDataToServer(exercise, weight, sets, reps);
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> sendDataToServer(dynamic e, double w, int s, int r) async {
  const String apiUrl = 'https://gymapp-hb.azurewebsites.net/api/exercises';

  final vastaus = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({"exercise": e, "weight": w, "sets": s, "reps": r}),
  );

  if (vastaus.statusCode == 200) {
    print(vastaus.body);
  }
  else print(vastaus.body);
}