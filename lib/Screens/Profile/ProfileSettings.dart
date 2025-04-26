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
  // late TextEditingController _policeStationController;
  late TextEditingController _rankController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  bool _isLoading = true;
  late Future<Map<String, dynamic>> _profileFuture;

  final List<String> _policeStations = [
    'Colombo Central',
    'Kandy',
    'Galle',
    'Jaffna',
    'Batticaloa',
    'Negombo',
    'Anuradhapura',
    'Matara',
  ];
  String _selectedPoliceStation = '';
  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values first
    _fullNameController = TextEditingController();
    // _policeStationController = TextEditingController();
    _rankController = TextEditingController();
    _contactNumberController = TextEditingController();
    _emailController = TextEditingController();

    // Initialize the future only once
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _profileFuture = authProvider.getProfileDetails(authProvider.officerId);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    // _policeStationController.dispose();
    _rankController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Initialize controllers with fetched data
            _fullNameController.text = authProvider.officerName;
            if (_selectedPoliceStation.isEmpty) {
              _selectedPoliceStation = authProvider.policeStation;
            }

            _rankController.text = authProvider.officerRank ?? '';
            _contactNumberController.text = authProvider.contactNumber ?? '';
            _emailController.text = authProvider.email ?? '';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your name' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedPoliceStation.isNotEmpty
                            ? _selectedPoliceStation
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Police Station',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        items: _policeStations
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            print(newValue);
                            setState(() {
                              _selectedPoliceStation = newValue;
                            });
                          }
                        },
                        validator: (value) => value == null || value.isEmpty
                            ? 'Please select a police station'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rankController,
                        decoration: const InputDecoration(
                          labelText: 'Rank',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.military_tech),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter your rank' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contactNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter your contact number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      profileProvider.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  print(_selectedPoliceStation);
                                  final success =
                                      await profileProvider.updateProfile(
                                    officerId: authProvider.officerId,
                                    fullName: _fullNameController.text,
                                    policeStation: _selectedPoliceStation,
                                    rank: _rankController.text,
                                    contactNumber:
                                        _contactNumberController.text,
                                    email: _emailController.text,
                                  );

                                  if (success) {
                                    // Refresh auth data
                                    await authProvider.getProfileDetails(
                                        authProvider.officerId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Profile updated successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error: ${profileProvider.error}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.darkBlue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
