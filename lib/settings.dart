import 'package:appp/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notifications = true;
  bool _soundsEnabled = true;
  bool _isSyncing = false;

  void _syncDatabase() async {
    setState(() {
      _isSyncing = true;
    });
    // Simulate database sync
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Database synced successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully")),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/newLogin', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Attempt to get current user info
    final currentUser = FirebaseAuth.instance.currentUser;
    final String userEmail = currentUser?.email ?? "admin@waterpark.com";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Profile Header card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                    child: Text(
                      userEmail.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Waterpark Staff",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Admin",
                      style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Settings Section: General
          _buildSectionHeader("App Preferences"),
          _buildSettingsTile(
            title: "Dark Mode",
            subtitle: "Enable dark themed layouts",
            leadingIcon: Icons.dark_mode_rounded,
            trailingWidget: Switch(
              value: themeNotifier.value == ThemeMode.dark,
              activeThumbColor: Colors.blueAccent,
              onChanged: (val) {
                setState(() {
                  themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
          ),
          _buildSettingsTile(
            title: "Push Notifications",
            subtitle: "Receive ticket verification notifications",
            leadingIcon: Icons.notifications_rounded,
            trailingWidget: Switch(
              value: _notifications,
              activeThumbColor: Colors.blueAccent,
              onChanged: (val) {
                setState(() {
                  _notifications = val;
                });
              },
            ),
          ),
          _buildSettingsTile(
            title: "Sound Effects",
            subtitle: "Play sounds on scan verification",
            leadingIcon: Icons.volume_up_rounded,
            trailingWidget: Switch(
              value: _soundsEnabled,
              activeThumbColor: Colors.blueAccent,
              onChanged: (val) {
                setState(() {
                  _soundsEnabled = val;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // Settings Section: Admin Utilities
          _buildSectionHeader("Administrative Utilities"),
          _buildSettingsTile(
            title: "Sync Database",
            subtitle: "Fetch latest ticket records from server",
            leadingIcon: Icons.sync_rounded,
            trailingWidget: _isSyncing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onPressed: _syncDatabase,
                  ),
            onTap: _isSyncing ? null : _syncDatabase,
          ),
          _buildSettingsTile(
            title: "Clear Cache",
            subtitle: "Delete local assets cache (1.2 MB)",
            leadingIcon: Icons.delete_outline_rounded,
            trailingWidget: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Cache cleared successfully!")),
              );
            },
          ),
          const SizedBox(height: 24),

          // Settings Section: About & Support
          _buildSectionHeader("Support & Info"),
          _buildSettingsTile(
            title: "Help & Feedback",
            subtitle: "Contact development support team",
            leadingIcon: Icons.help_outline_rounded,
            trailingWidget: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "AquaFun Management",
                applicationVersion: "v1.0.0",
                applicationIcon: const Icon(Icons.pool_rounded, color: Colors.blueAccent, size: 40),
                children: const [
                  Padding(
                    padding: EdgeInsets.only(top: 12.0),
                    child: Text("AquaFun Management App allows park staff to issue tickets, view real-time entry logs, track attendance analytics, and verify entry via QR code scan simulations."),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Logout Button
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            label: const Text("Log Out", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blue[900]?.withValues(alpha: 0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    required Widget trailingWidget,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(leadingIcon, color: Colors.blueAccent, size: 24),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: trailingWidget,
      ),
    );
  }
}