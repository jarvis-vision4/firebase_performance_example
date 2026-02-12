import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_performance_example/firebase_options.dart';

import 'package:firebase_performance_example/ui/performance_home.dart';
import 'package:flutter/material.dart';

import 'observer/performance_route_observer.dart';
import 'ui/detail_screen.dart';
import 'ui/heavy_rendering_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PerformanceRouteObserver routeObserver = PerformanceRouteObserver();

  MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Performance Complete Demo',
      navigatorObservers: [routeObserver],
      home: PerformanceHomePage(),
      routes: {
        '/details': (context) => DetailScreen(),
        '/heavy': (context) => HeavyRenderingScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
