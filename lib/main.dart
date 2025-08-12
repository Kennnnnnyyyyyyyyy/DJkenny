import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'core/supabase_client.dart';
import 'router/router_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase using Env-based bootstrap
  await initSupabase();
  
  // Initialize Superwall for iOS
  await Superwall.configure('pk_faef7874706620e075c87409d669b260cd9ef40f8cc09eca');
  
  runApp(const MyApp());
}

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
          fontFamily: 'Manrope',
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}

