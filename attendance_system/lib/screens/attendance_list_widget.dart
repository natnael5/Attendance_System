import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceListWidget extends StatelessWidget {
  final String subjectName;

  AttendanceListWidget({required this.subjectName});

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .doc(subjectName.toLowerCase())
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        List<dynamic>? students =
            snapshot.data?.get('students') as List<dynamic>?;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Attended Students for $subjectName',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'Date: ${_formatDate(currentDate)}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: students?.length ?? 0,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 4.0),
                    child: ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 0.0,
                        horizontal: 8.0,
                      ),
                      title: Text(
                        '${index + 1}. ${students?[index] ?? ''}',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to format the date as 'YYYY-MM-DD'
  String _formatDate(DateTime date) {
    return '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
  }

  // Helper method to add a leading zero if the number is a single digit
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
