import 'package:flutter/material.dart';
import 'student_home_screen.dart';

class AttendanceConfirmationScreen extends StatelessWidget {
  final String subjectName;
  final String username;

  // Constructor to initialize the subjectName and username
  AttendanceConfirmationScreen(this.subjectName, String userEmail)
      : username = userEmail.split('@')[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Confirmation'),
        // Remove the right icon
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            print('Back button pressed');
            // Replace the current route with the StudentHomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => StudentHomeScreen(username),
              ),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100.0,
            ),
            SizedBox(height: 16.0),
            Text(
              'You have successfully attended for',
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.0),
            Text(
              '$subjectName',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
