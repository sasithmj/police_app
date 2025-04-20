import 'package:flutter/material.dart';
import 'package:police_app/Screens/Authentication/Login.dart';
import 'package:police_app/Screens/LogViolations/OfficerLogDetails.dart';
import 'package:police_app/Screens/Profile/ProfileSettings.dart';
import 'package:police_app/main.dart';
import 'package:police_app/theme/AppColors.dart';
import 'package:police_app/Providers/AuthProvider.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Officer Profile',
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.darkBlue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.mediumBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      authProvider.officerName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authProvider.officerId,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              _buildMenuItem(
                context,
                icon: Icons.assessment,
                title: 'Log Violations',
                iconColor: const Color.fromARGB(255, 126, 171, 214),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoggedViolationsScreen(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.person_outline,
                title: 'Profile Settings',
                iconColor: const Color.fromARGB(255, 107, 111, 206),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfileSettingsScreen()),
                  );
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.logout,
                title: 'Log out',
                iconColor: Colors.red,
                onTap: () async {
                  bool confirm = await _showLogoutConfirmationDialog(context);
                  if (confirm) {
                    authProvider.logout();
                    if (confirm && mounted) {
                      MyApp.navigatorKey.currentState!.pushReplacement(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    }
                  }
                },
                showDivider: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color iconColor,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        if (showDivider) const SizedBox(height: 20),
      ],
    );
  }

  Future<bool> _showLogoutConfirmationDialog(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Log Out'),
                onPressed: () {
                  authProvider.logout();
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          ),
        ) ??
        false;
  }
}
