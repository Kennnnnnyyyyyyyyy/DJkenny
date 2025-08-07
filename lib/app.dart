import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/router_config.dart'; // Import the router

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'MELO AI',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          fontFamily: 'Manrope', // Set Manrope as the default font for the entire app
          useMaterial3: true,
        ),
        routerConfig: router, // Use the GoRouter configuration
      ),
    );
  }
}
