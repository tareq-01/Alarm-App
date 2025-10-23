import 'package:flutter/material.dart';

class AlarmRingScreen extends StatelessWidget {
  final String alarmTitle;
  final VoidCallback onStop;
  final VoidCallback? onSnooze;

  const AlarmRingScreen({
    Key? key,
    required this.alarmTitle,
    required this.onStop,
    this.onSnooze,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           
            
            SizedBox(height: 24),
            
            Text(
              alarmTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
           
            SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onStop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'STOP',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}