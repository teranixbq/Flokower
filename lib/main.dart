import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'shared/theme/flokower_theme.dart';

import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/inventory/presentation/screens/stock_screen.dart';
import 'features/transactions/presentation/screens/product_gallery_screen.dart';
import 'features/transactions/presentation/screens/active_orders_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Always load .env (needed for R2 credentials etc.)
  await dotenv.load(fileName: ".env");

  if (kIsWeb) {
    // Web: init Firebase with options from .env
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // Android/iOS: Firebase reads from google-services.json / GoogleService-Info.plist
    await Firebase.initializeApp();
  }

  runApp(const ProviderScope(child: FlokowerApp()));
}

class FlokowerApp extends StatelessWidget {
  const FlokowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flokower',
      debugShowCheckedModeBanner: false,
      theme: FlokowerTheme.light,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/flokower-logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  const Text('Flokower', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  const SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: FlokowerTheme.mediumGray),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasData) return const MainScreen();
        return const AuthScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    ActiveOrdersScreen(),
    StockScreen(),
    ReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.hourglass_empty), activeIcon: Icon(Icons.hourglass_full), label: 'Proses'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: 'Stok'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Laporan'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              heroTag: 'new_order',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductGalleryScreen())),
              backgroundColor: FlokowerTheme.accentTeal,
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.add_rounded),
            )
          : null,
    );
  }
}
