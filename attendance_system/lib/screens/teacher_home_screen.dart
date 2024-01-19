import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'attendance_list_widget.dart';
import 'package:attendance_system/main.dart';

class TeacherHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: 100.0,
            color: Colors.blue,
          ),
          SizedBox(height: 20.0),
          Text(
            'Welcome, Teacher!',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.0),
          Expanded(
            child: _buildAttendanceList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? teacherEmail = user?.email;
    String? subjectName = _extractSubjectName(teacherEmail);

    if (subjectName == null) {
      return Center(
        child: Text('Subject name not found.'),
      );
    }

    return AttendanceListWidget(subjectName: subjectName);
  }

  String? _extractSubjectName(String? email) {
    if (email == null) return null;

    List<String> parts = email.split('@');
    if (parts.length == 2) {
      return parts[0];
    } else {
      return null;
    }
  }
}
