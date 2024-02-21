import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HistoryPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _retrieveData() async {
    return await retrieveDataFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {},
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _retrieveData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              List<Map<String, dynamic>> data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Exercise: ${data[index]['exercise']}'),
                    subtitle: Text('Weight: ${data[index]['weight']}, Sets: ${data[index]['sets']}, Reps: ${data[index]['reps']}'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

Future<List<Map<String, dynamic>>> retrieveDataFromServer() async {
  const String apiUrl = 'https://gymapp-hb.azurewebsites.net/api/exercises';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = json.decode(response.body);
    final List<Map<String, dynamic>> data = [];

    // Iterate through the jsonData and convert each entry to Map<String, dynamic>
    jsonData.forEach((key, value) {
      data.add(Map<String, dynamic>.from(value));
    });

    return data;
  } else {
    print('Failed to load data: ${response.statusCode}');
    return [];
  }
}