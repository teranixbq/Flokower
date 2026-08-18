import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/flokower_theme.dart';

/// Reusable Settings button for AppBar actions.
/// Shows user info + logout menu.
/// Usage: AppBar(actions: [SettingsButton()])
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.settings_outlined, color: FlokowerTheme.darkGray),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        offset: const Offset(0, 48),
        onSelected: (value) async {
          if (value == 'logout') {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Keluar?', style: TextStyle(fontWeight: FontWeight.w700)),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Keluar', style: TextStyle(color: FlokowerTheme.accentRed, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await FirebaseAuth.instance.signOut();
            }
          }
        },
        itemBuilder: (context) => [
          // User info header
          PopupMenuItem(
            enabled: false,
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: FlokowerTheme.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Pengguna',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: FlokowerTheme.black),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(fontSize: 11, color: FlokowerTheme.mediumGray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuItem(enabled: false, height: 1, child: Divider(height: 1)),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout_rounded, color: FlokowerTheme.accentRed, size: 20),
                SizedBox(width: 10),
                Text('Keluar', style: TextStyle(color: FlokowerTheme.accentRed, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
