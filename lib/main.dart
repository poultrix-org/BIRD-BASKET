import 'package:birdbasket/screens/authentications/splashscreens/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- 1. Import Supabase

void main() async { // <-- 2. Make main async
  WidgetsFlutterBinding.ensureInitialized(); // <-- 3. Ensure Flutter is ready

  // --- 4. Initialize Supabase ---
  // Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://msbzwhmynrogycvrwwjd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1zYnp3aG15bnJvZ3ljdnJ3d2pkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMzMDU5OTgsImV4cCI6MjA3ODg4MTk5OH0.fUg-HZdvRWkI7lm3SK8xQUkKTU2QbX4M3PbXr61idxw',
  );
  // ---------------------------------

  runApp(const HenHutApp()); // <-- 5. Run the app
}

class HenHutApp extends StatelessWidget {
  const HenHutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HenHut',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.brown[700]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashView(),
    );
  }
}