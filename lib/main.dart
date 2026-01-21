import 'package:flutter/material.dart';
import 'package:live_location_tracker/providers/geo_fence_provider.dart';
import 'package:live_location_tracker/screens/map_screen.dart';
import 'package:live_location_tracker/services/notification_services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => GeofenceProvider(), child: MapScreen()),
    ],
    child: MyApp(),
    )
    ,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Location Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MapScreen(),

    );
  }
}
