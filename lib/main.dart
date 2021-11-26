import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_irrigation/Providers/firebase.dart';
import 'package:smart_irrigation/Providers/sensor_data.dart';
import 'package:smart_irrigation/Providers/threshold.dart';
import 'package:smart_irrigation/Screens/home_page.dart';
import 'package:smart_irrigation/Screens/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (_) => runApp(
      const Cover(),
    ),
  );
}

class Cover extends StatelessWidget {
  const Cover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SensorDataProvider()),
        ChangeNotifierProvider(create: (context) => ThresholdProvider()),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 0), () async {
      await FirebaseDB().fetchDB(context);
      // await Provider.of<ThresholdProvider>(context, listen: false)
      //     .getThresholdDataFromDb();
      // await Provider.of<SensorDataProvider>(context, listen: false)
      //     .getSensorDataFromDb();
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agrita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(primary: Colors.blueGrey),
        ),
      ),
      home: isLoading ? const LoadingScreen() : const HomePage(),
    );
  }
}
