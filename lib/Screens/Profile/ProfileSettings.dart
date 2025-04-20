import 'package:flutter/material.dart';
import 'package:police_app/Providers/AuthProvider.dart';
import 'package:police_app/theme/AppColors.dart';
import 'package:provider/provider.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  _ProfileSettingsScreenState createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _policeStationController;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _fullNameController = TextEditingController(text: authProvider.officerName);
    _policeStationController =
        TextEditingController(text: authProvider.policeStation);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _policeStationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            color: AppColors.darkBlue,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 249, 249, 249),
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              TextFormField(
                controller: _policeStationController,
                decoration: const InputDecoration(labelText: 'Police Station'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your police station' : null,
              ),
              const SizedBox(height: 20),
              profileProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final success = await profileProvider.updateProfile(
                            officerId: authProvider.officerId,
                            fullName: _fullNameController.text,
                            policeStation: _policeStationController.text,
                          );
                          if (success) {
                            authProvider.login(authProvider.officerId,
                                ''); // Refresh auth data
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profile updated successfully')),
                            );
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Error: ${profileProvider.error}')),
                            );
                          }
                        }
                      },
                      child: const Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
