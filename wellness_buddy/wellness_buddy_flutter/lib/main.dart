import 'package:wellness_buddy_client/wellness_buddy_client.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'screens/home_screen.dart';

/// Global Serverpod client
late final Client client;

// ──────────────────────────────────────────────
//  Aara Color Palette
// ──────────────────────────────────────────────
class AaraColors {
  // Brand palette
  static const iceCold      = Color(0xFFa0d2eb); // #a0d2eb — highlights, links
  static const freezePurple = Color(0xFFe5eaf5); // #e5eaf5 — light text, chips
  static const medPurple    = Color(0xFFd0bdf4); // #d0bdf4 — secondary text
  static const purplePain   = Color(0xFF8458B3); // #8458B3 — primary accent
  static const heavyPurple  = Color(0xFFa28089); // #a28089 — muted text

  // Dark backgrounds (derived from palette)
  static const bg           = Color(0xFF080C14); // near-black, ice-tinted
  static const surface      = Color(0xFF101520); // card background
  static const border       = Color(0xFF1E2A3A); // subtle borders
  static const hintText     = Color(0xFF2A3850); // placeholder text
  static const labelText    = Color(0xFF4A6070); // section labels
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final serverUrl = await getServerUrl();

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

  client.auth.initialize();

  runApp(const AaraApp());
}

class AaraApp extends StatelessWidget {
  const AaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aara — Student Wellness',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: AaraColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AaraColors.purplePain,
        secondary: AaraColors.iceCold,
        surface: AaraColors.surface,
        onPrimary: Colors.white,
        onSurface: AaraColors.freezePurple,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
        bodyColor: AaraColors.freezePurple,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AaraColors.bg,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AaraColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AaraColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AaraColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AaraColors.iceCold, width: 1.5),
        ),
        hintStyle: GoogleFonts.nunito(color: AaraColors.hintText),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AaraColors.purplePain,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: AaraColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AaraColors.border),
        ),
        elevation: 0,
      ),
    );
  }
}
