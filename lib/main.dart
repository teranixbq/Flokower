import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Load .env file BEFORE Firebase init
  await dotenv.load(fileName: ".env");

  // Now Firebase can read env values
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), activeIcon: Icon(Icons.grid_view_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2_rounded), label: 'Stok'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart_rounded), label: 'Laporan'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'active_orders',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ActiveOrdersScreen())),
                  backgroundColor: FlokowerTheme.charcoal,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.pending_actions_rounded, size: 20),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'new_order',
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductGalleryScreen())),
                  backgroundColor: FlokowerTheme.black,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            )
          : null,
    );
  }
}
