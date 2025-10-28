// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:audio_session/audio_session.dart';
// import 'package:flutter/material.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Simple Alarm App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: AlarmScreen(),
//     );
//   }
// }

// // ===================================================
// // lib/screens/alarm_screen.dart

// class AlarmScreen extends StatefulWidget {
//   @override
//   _AlarmScreenState createState() => _AlarmScreenState();
// }

// class _AlarmScreenState extends State<AlarmScreen> {
//   final AlarmAudioPlayer _audioPlayer = AlarmAudioPlayer();

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Alarm Audio')),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 _audioPlayer.initializeAndPlay('assets/sounds/alarm1.mp3');
//               },
//               child: Text('Play Alarm'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _audioPlayer.stop();
//               },
//               child: Text('Stop Alarm'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ===================================================
// // lib/services/alarm_audio_player.dart

// class AlarmAudioPlayer {
//   final AudioPlayer _player = AudioPlayer();
//   static const platform = MethodChannel('com.example.alarm_app/audio');

//   Future<void> initializeAndPlay(String audioPath) async {
//     try {
//       // Set audioo stream to ALARM via platform channel
//       await _setAlarmAudioStream();

//       // Configure audio session
//       final session = await AudioSession.instance;
//       await session.configure(
//         AudioSessionConfiguration(
//           avAudioSessionCategory: AVAudioSessionCategory.playback,
//           avAudioSessionMode: AVAudioSessionMode.defaultMode,
//           avAudioSessionCategoryOptions:
//               AVAudioSessionCategoryOptions.duckOthers,
//           androidAudioAttributes: const AndroidAudioAttributes(
//             contentType: AndroidAudioContentType.sonification,
//             usage: AndroidAudioUsage.alarm,
//           ),
//           androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
//         ),
//       );

//       // Load and play audio
//       await _player.setAsset(audioPath);
//       await _player.play();
//     } catch (e) {
//       print('Error playing audio: $e');
//     }
//   }

//   Future<void> _setAlarmAudioStream() async {
//     try {
//       await platform.invokeMethod('setAlarmStream');
//     } on PlatformException catch (e) {
//     }
//   }

//   Future<void> stop() async {
//     await _player.stop();
//     await _resetAudioStream();
//   }

//   Future<void> _resetAudioStream() async {
//     try {
//       await platform.invokeMethod('resetAudioStream');
//     } on PlatformException catch (e) {
//       print("Failed to reset audio stream: '${e.message}'.");
//     }
//   }

//   void dispose() {
//     _player.dispose();
//   }
// }


import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Global instances
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// This function must be a top-level function or static method
@pragma('vm:entry-point')
void alarmCallback() async {
  print('Alarm triggered!');
  
  // Show full-screen notification
  await _showFullScreenNotification();
}

Future<void> _showFullScreenNotification() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alarm_channel',
    'Alarm Notifications',
    channelDescription: 'Channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    sound: RawResourceAndroidNotificationSound('alarm_sound'), // Add your alarm sound
    playSound: true,
    enableVibration: true,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Alarm Ringing!',
    'Tap to stop the alarm',
    notificationDetails,
    payload: 'alarm_screen',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Android Alarm Manager
  await AndroidAlarmManager.initialize();
  
  // Initialize notifications
  await _initializeNotifications();
  
  runApp(const MyApp());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  
  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload == 'alarm_screen') {
        // Navigate to alarm screen
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => AlarmRingingScreen()),
        );
      }
    },
  );

  // Create notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'alarm_channel',
    'Alarm Notifications',
    description: 'Channel for alarm notifications',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AlarmHomePage(),
    );
  }
}

class AlarmHomePage extends StatefulWidget {
  const AlarmHomePage({Key? key}) : super(key: key);

  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _alarmSet = false;

  Future<void> _scheduleAlarm() async {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final success = await AndroidAlarmManager.oneShotAt(
      scheduledDate,
      0, // Alarm ID
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    if (success) {
      setState(() => _alarmSet = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Alarm set for ${_selectedTime.format(context)}'),
        ),
      );
      
      // Save alarm state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('alarm_set', true);
    }
  }

  Future<void> _cancelAlarm() async {
    await AndroidAlarmManager.cancel(0);
    setState(() => _alarmSet = false);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_set', false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alarm cancelled')),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm, size: 100, color: Colors.blue),
            const SizedBox(height: 40),
            Text(
              _selectedTime.format(context),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _selectTime,
              icon: const Icon(Icons.access_time),
              label: const Text('Select Time'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 30),
            if (!_alarmSet)
              ElevatedButton.icon(
                onPressed: _scheduleAlarm,
                icon: const Icon(Icons.alarm_add),
                label: const Text('Set Alarm'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _cancelAlarm,
                icon: const Icon(Icons.alarm_off),
                label: const Text('Cancel Alarm'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            const SizedBox(height: 20),
            if (_alarmSet)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Alarm is active',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AlarmRingingScreen(),
                  ),
                );
              },
              child: const Text('Test Alarm Screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({Key? key,}) : super(key: key);

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _stopAlarm() async {
    // Cancel the notification
    await flutterLocalNotificationsPlugin.cancel(0);
    
    // Cancel the alarm
    await AndroidAlarmManager.cancel(0);
    
    // Update alarm state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_set', false);
    
    // Close the screen
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_controller.value * 0.2),
                    child: const Icon(
                      Icons.alarm,
                      size: 150,
                      color: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'ALARM!',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                TimeOfDay.now().format(context),
                style: const TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: _stopAlarm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 20,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stop_circle, size: 32),
                    SizedBox(width: 10),
                    Text(
                      'STOP',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
