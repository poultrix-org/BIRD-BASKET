import 'package:birdbasket/screens/authentications/auths/controllers/global_auth_controller.dart';
import 'package:birdbasket/screens/authentications/auths/views/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- 1. Import Supabase

void main() async {
  // <-- 2. Make main async
  WidgetsFlutterBinding.ensureInitialized(); // <-- 3. Ensure Flutter is ready

  // --- 4. Initialize Supabase ---
  // Replace with your actual Supabase URL and Anon Key
  await Supabase.initialize(
    url: 'https://eogadomstatzpewhwpmi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVvZ2Fkb21zdGF0enBld2h3cG1pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxMjIxMTAsImV4cCI6MjA5MDY5ODExMH0.2S8za7XrhXi2I_eUVdvHSAT-MUi0Km5r15GA6aIS0Xc',
  );
  // ---------------------------------

  runApp(const HenHutApp()); // <-- 5. Run the app
}

class HenHutApp extends StatelessWidget {
  const HenHutApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the elegant, minimal farming color palette
    const Color primaryOlive = Color(0xFF5D654E);
    const Color backgroundBone = Color(0xFFF7F8F3);
    const Color inputFill = Color(0xFFFAFAFA);
    const Color subtleBorder = Color(0xFFE2E4DA);
    const Color textDark = Colors.black87;

    Get.put(GlobalAuthController(), permanent: true);
    return GetMaterialApp(
      title: 'HenHut',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryOlive,
          primary: primaryOlive,
          surface: backgroundBone,
          onSurface: textDark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF1B5E20)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1B5E20), // Dark green headings globally
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(
              0xFF1E2019,
            ), // Deep rich black-olive for main buttons
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            elevation: 0,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            shape: const StadiumBorder(),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: textDark,
            side: const BorderSide(color: subtleBorder, width: 1.5),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: inputFill,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textDark,
          ),
          hintStyle: TextStyle(color: textDark.withOpacity(0.4), fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: subtleBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: subtleBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryOlive, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: subtleBorder),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        dividerTheme: const DividerThemeData(
          color: subtleBorder,
          thickness: 1,
          space: 24,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          disabledColor: Colors.white,
          selectedColor: primaryOlive,
          secondarySelectedColor: primaryOlive,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          labelStyle: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w500,
          ),
          secondaryLabelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          brightness: Brightness.light,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: subtleBorder),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryOlive,
          unselectedItemColor: Colors.grey,
          elevation: 20,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
      builder: (context, child) {
        return Material(
          color: const Color(0xFFF7F8F3), // base bone color
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.27,
                  child: Image.asset(
                    'assets/images/pattern.png',
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
              if (child != null) child,
            ],
          ),
        );
      },
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}
