import 'dart:io'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:permission_handler/permission_handler.dart'; 
import 'dart:convert';
  
// To save the file in the device 
class FileStorage { 
  static Future<String> getExternalDocumentPath() async { 
    // To check whether permission is given for this app or not. 
    var status = await Permission.storage.status; 
    if (!status.isGranted) { 
      // If not we will ask for permission first 
      await Permission.storage.request(); 
    } 
    Directory _directory = Directory(""); 
    if (Platform.isAndroid) { 
       // Redirects it to download folder in android 
      _directory = Directory("/storage/emulated/0/Download"); 
    } else { 
      _directory = await getApplicationDocumentsDirectory(); 
    } 
  
    final exPath = _directory.path; 
    //print("Saved Path: $exPath"); 
    await Directory(exPath).create(recursive: true); 
    return exPath; 
  } 
  
  static Future<String> get _localPath async { 
    // final directory = await getApplicationDocumentsDirectory(); 
    // return directory.path; 
    // To get the external path from device of download folder 
    final String directory = await getExternalDocumentPath(); 
    return directory; 
  } 

  static Future<bool> fileExists(String filename) async {
    try {
      final file = await _getWorkoutFile(filename);
      return file.exists();
    } catch (e) {
      print('Error checking if file exists: $e');
      return false;
    }
  }
  
  
static Future<File> writeCounter(String bytes, String name) async {
  try {
    final path = await _localPath;
    File file = File('$path/$name');

    if (await fileExists(name)) {
      String existingContent = await file.readAsString();

      // Ensure that the existing content is not empty
      if (existingContent.isNotEmpty) {
        // Remove the closing brace '}' to append new content
        existingContent = existingContent.substring(0, existingContent.length - 1);

        // Append a comma before adding new content
        existingContent += ',';

        if (bytes.startsWith('{')) {
          bytes = bytes.substring(1);
        }
      }

      // Append the new content to the existing content
      String jsonContent = '$existingContent$bytes';

      // Write the JSON content to the file
      return file.writeAsString(jsonContent, mode: FileMode.write);
    } else {
      // If the file doesn't exist, simply write the new data
      return file.writeAsString(bytes, mode: FileMode.write);
    }
  } catch (e) {
    print('Error writing file: $e');
    throw e; // Rethrow the error for handling in the caller
  }
}

  static Future<void> removeElement(String key, String filename) async {
    try {
      final File file = await _getWorkoutFile(filename);
      String content = await file.readAsString();

      // Parse the content as JSON-like structure
      Map<String, dynamic> data = json.decode(content);

      // Remove the workout entry
      if (data.containsKey(key)) {
        print("removing: $key");
        data.remove(key);
      }

      // Write the updated contents back to the file
      await file.writeAsString(json.encode(data));
    } catch (e) {
      print('Error removing workout: $e');
    }
  }

  static Future<Map<String, dynamic>> readFile(String filename) async {
    try {
      final File file = await _getWorkoutFile(filename);
      String content = await file.readAsString();

      // Parse the content as JSON-like structure
      Map<String, dynamic> data = json.decode('$content');

      //print(data);

      return data;

    } catch (e) {
      print('Error reading workouts: $e');
      Map<String, dynamic> data2 = {"Error":[{"No workouts yet :(":""}]};
      return data2;
    }
  }

 static Future<List<String>> readKeys(String filename) async {
    try {
      final File file = await _getWorkoutFile(filename);
      String content = await file.readAsString();

      // Parse the content as JSON-like structure
      Map<String, dynamic> data = json.decode('$content');

      List<String> keys = data.keys.toList();

      return keys;

    } catch (e) {
      print('Error reading workouts keys: $e');
      List<String> nullKeys = [];
      return nullKeys;
    }
  }
  
  static Future<File> _getWorkoutFile(String name) async {
    final path = await _localPath;
    return File('$path/$name');
  }
}
