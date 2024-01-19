import 'package:flutter/material.dart';
import 'package:attendance_system/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'attendance_confirmation_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  final String username;

  StudentHomeScreen(this.username);

  // Method to sign out the user
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {},
            ),
            Text(
              'Student Home - $username',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _signOut(context),
          ),
        ],
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: QRScannerWidget(username: username),
      ),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  final String username;

  QRScannerWidget({required this.username});

  @override
  _QRScannerWidgetState createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget>
    with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool attended = false;
  String? subjectName;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for the custom QR code animation
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    animationController.forward();

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildQRView(context),
        _buildCustomQRAnimation(),
        Positioned(
          top: 150,
          child: Text(
            'Scan QR Code',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.lightBlue,
            ),
          ),
        ),
      ],
    );
  }

  // Widget to build the QR code scanner view
  Widget _buildQRView(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: 300,
      ),
    );
  }

  // Widget to build the custom QR code animation
  Widget _buildCustomQRAnimation() {
    return Container(
      width: 300,
      height: 300,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return _buildRedLine(animationController.value);
            },
          ),
        ],
      ),
    );
  }

  // Widget to build the red line in the custom QR code animation
  Widget _buildRedLine(double animationValue) {
    return Positioned(
      top: 0,
      child: Container(
        width: 300,
        height: 2,
        color: Colors.red,
        margin: EdgeInsets.only(top: 300 * animationValue),
      ),
    );
  }

  // Callback when QR code is scanned
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (!attended) {
        subjectName = scanData.code;

        // Update attendance in Firestore
        await _updateAttendance(subjectName);

        setState(() {
          attended = true;
        });

        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceConfirmationScreen(
              subjectName ?? '',
              widget.username,
            ),
          ),
        );
      } else {
        print('Already attended.');
      }
    });
  }

  Future<void> _updateAttendance(String? subjectName) async {
    try {
      if (subjectName != null) {
        String userName = widget.username;
        CollectionReference attendanceCollection =
            FirebaseFirestore.instance.collection('attendance');

        // Update attendance document in Firestore
        await attendanceCollection.doc(subjectName).set({
          'students': FieldValue.arrayUnion([userName]),
        }, SetOptions(merge: true));

        print('Attendance updated in Firestore.');
      } else {
        print('Subject name is null.');
      }
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    animationController.dispose();
    super.dispose();
  }
}
