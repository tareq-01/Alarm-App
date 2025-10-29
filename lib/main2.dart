import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// Top-level callback
@pragma('vm:entry-point')
void alarmCallback() async {
  // Save alarm state
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('alarm_ringing', true);
  await initializeNotifications();

  // Show full screen intent notification - this WILL wake the screen
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'alarm_channel_id',
    'Alarms',
    channelDescription: 'Alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    playSound: true,
    enableVibration: true,
    ongoing: true,
    autoCancel: false,
  );

  const NotificationDetails details = NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(999, 'ALARM RINGING!', 'Tap to open', details, payload: "alarm-screen");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize();
  await initializeNotifications();

  runApp(const MyApp());
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(android: androidSettings));

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'alarm_channel_id',
    'Alarms',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AlarmWrapper(),
    );
  }
}

// Wrapper to check alarm state on start
class AlarmWrapper extends StatefulWidget {
  const AlarmWrapper({Key? key}) : super(key: key);

  @override
  State<AlarmWrapper> createState() => _AlarmWrapperState();
}

class _AlarmWrapperState extends State<AlarmWrapper> {
  bool _checking = true;
  bool _alarmRinging = false;

  @override
  void initState() {
    super.initState();
    _checkAlarmStatus();
  }

  Future<void> _checkAlarmStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isRinging = prefs.getBool('alarm_ringing') ?? false;

    setState(() {
      _alarmRinging = isRinging;
      _checking = false;
    });

    if (isRinging) {
      WakelockPlus.enable();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_alarmRinging) {
      return const AlarmRingingScreen();
    }

    return const AlarmHomePage();
  }
}

class AlarmHomePage extends StatefulWidget {
  const AlarmHomePage({Key? key}) : super(key: key);

  @override
  State<AlarmHomePage> createState() => _AlarmHomePageState();
}

class _AlarmHomePageState extends State<AlarmHomePage> with WidgetsBindingObserver {
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isAlarmSet = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      final prefs = await SharedPreferences.getInstance();
      final isRinging = prefs.getBool('alarm_ringing') ?? false;

      if (isRinging && mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AlarmRingingScreen()));
      }
    }
  }

  Future<void> _setAlarm() async {
    final now = DateTime.now();
    var alarmTime = DateTime(now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

    if (alarmTime.isBefore(now)) {
      alarmTime = alarmTime.add(const Duration(days: 1));
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_ringing', false);

    await AndroidAlarmManager.cancel(1);

    final success = await AndroidAlarmManager.oneShotAt(alarmTime, 1, alarmCallback, exact: true, wakeup: true, rescheduleOnReboot: true, allowWhileIdle: true);

    if (success) {
      setState(() {
        isAlarmSet = true;
      });

      final diff = alarmTime.difference(now);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Alarm set for ${selectedTime.format(context)}\n'
              'Rings in ${diff.inHours}h ${diff.inMinutes % 60}m',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _cancelAlarm() async {
    await AndroidAlarmManager.cancel(1);
    await flutterLocalNotificationsPlugin.cancel(999);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_ringing', false);

    setState(() {
      isAlarmSet = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alarm cancelled')));
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _testAlarm() async {
    final testTime = DateTime.now().add(const Duration(seconds: 15));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_ringing', false);

    await AndroidAlarmManager.cancel(1);

    final success = await AndroidAlarmManager.oneShotAt(testTime, 1, alarmCallback, exact: true, wakeup: true, allowWhileIdle: true);

    if (success && mounted) {
      setState(() {
        isAlarmSet = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test alarm in 15 seconds!\n🔒 LOCK YOUR PHONE NOW!'), backgroundColor: Colors.blue, duration: Duration(seconds: 4)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm App'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isAlarmSet ? Icons.alarm_on : Icons.alarm_off, size: 100, color: isAlarmSet ? Colors.green : Colors.grey),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: Column(
                  children: [
                    const Text('Alarm Time', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      selectedTime.format(context),
                      style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _selectTime,
                icon: const Icon(Icons.access_time),
                label: const Text('Change Time'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isAlarmSet ? null : _setAlarm,
                icon: const Icon(Icons.alarm_add),
                label: const Text('Set Alarm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: isAlarmSet ? _cancelAlarm : null,
                icon: const Icon(Icons.alarm_off),
                label: const Text('Cancel Alarm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    const Text('🧪 Quick Test', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(onPressed: _testAlarm, icon: const Icon(Icons.timer), label: const Text('Test Alarm (15 sec)')),
                    const SizedBox(height: 8),
                    const Text(
                      '⚠️ Lock phone after clicking!',
                      style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
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

class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({Key? key}) : super(key: key);

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String currentTime = '';

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();

    _animController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..repeat(reverse: true);

    _updateTime();
    _startTimeUpdater();
  }

  void _startTimeUpdater() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateTime();
        return true;
      }
      return false;
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    setState(() {
      currentTime = '$hour:$minute';
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _stopAlarm() async {
    await AndroidAlarmManager.cancel(1);
    await flutterLocalNotificationsPlugin.cancel(999);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_ringing', false);

    WakelockPlus.disable();

    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AlarmHomePage()));
    }
  }

  Future<void> _snoozeAlarm() async {
    await flutterLocalNotificationsPlugin.cancel(999);

    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    await AndroidAlarmManager.oneShotAt(snoozeTime, 1, alarmCallback, exact: true, wakeup: true, allowWhileIdle: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alarm_ringing', false);

    WakelockPlus.disable();

    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AlarmHomePage()));

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Snoozed for 5 minutes'), backgroundColor: Colors.orange));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade700,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.85, end: 1.15).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut)),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.alarm, size: 120, color: Colors.white),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                '⏰ ALARM',
                style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 4),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text(
                  currentTime,
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300, color: Colors.white),
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton(
                  onPressed: _stopAlarm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    elevation: 10,
                  ),
                  child: const Text('STOP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 70,
                child: OutlinedButton(
                  onPressed: _snoozeAlarm,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  ),
                  child: const Text('SNOOZE (5 MIN)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
