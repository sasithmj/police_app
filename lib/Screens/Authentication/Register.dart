import 'package:flutter/material.dart';
import 'package:police_app/Providers/AuthProvider.dart';
import 'package:police_app/theme/AppColors.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _fullNameController = TextEditingController();
  final _officerSVCController = TextEditingController();
  final _officerRankController = TextEditingController();
  // final _emailController = TextEditingController();
  // final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Dropdown value
  String _selectedPoliceStation = 'Colombo Central';

  // List of police stations
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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Registration'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Personal Information Section
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Officer ID
                TextFormField(
                  controller: _officerSVCController,
                  decoration: const InputDecoration(
                    labelText: 'Officer SVC No',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your officer SVC no';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),
                // Officer Rank
                TextFormField(
                  controller: _officerRankController,
                  decoration: const InputDecoration(
                    labelText: 'Officer Rank',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your officer Rank';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Police Station Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Police Station',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  value: _selectedPoliceStation,
                  items: _policeStations.map((station) {
                    return DropdownMenuItem(
                      value: station,
                      child: Text(station),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        _selectedPoliceStation = value;
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your police station';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // // Contact Information Section
                // Text(
                //   'Contact Information',
                //   style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //         color: Theme.of(context).colorScheme.tertiary,
                //         fontWeight: FontWeight.bold,
                //       ),
                // ),

                // const SizedBox(height: 16),

                // Email
                // TextFormField(
                //   controller: _emailController,
                //   keyboardType: TextInputType.emailAddress,
                //   decoration: const InputDecoration(
                //     labelText: 'Email Address',
                //     prefixIcon: Icon(Icons.email),
                //   ),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter your email';
                //     }
                //     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                //         .hasMatch(value)) {
                //       return 'Please enter a valid email';
                //     }
                //     return null;
                //   },
                // ),

                // const SizedBox(height: 16),

                // Phone
                // TextFormField(
                //   controller: _phoneController,
                //   keyboardType: TextInputType.phone,
                //   decoration: const InputDecoration(
                //     labelText: 'Phone Number',
                //     prefixIcon: Icon(Icons.phone),
                //     hintText: '+94 XX XXX XXXX',
                //   ),
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter your phone number';
                //     }
                //     return null;
                //   },
                // ),

                // const SizedBox(height: 32),

                // Security Section
                Text(
                  'Security Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Terms and Conditions
                Row(
                  children: [
                    Checkbox(
                      value: _agreedToTerms,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(
                              text: 'I agree to the ',
                            ),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text: ' and ',
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_agreedToTerms && !_isLoading)
                        ? _handleRegistration
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('REGISTER'),
                  ),
                ),

                const SizedBox(height: 16),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(color: AppColors.mediumBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userData = {
          'fullName': _fullNameController.text,
          'officerSVC': _officerSVCController.text,
          'officerRank': _officerRankController.text,
          'policeStation': _selectedPoliceStation,
          // 'email': _emailController.text,
          // 'phone': _phoneController.text,
          'Password': _passwordController.text,
        };

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.register(userData);

        if (success["success"] && mounted) {
          // Registration successful, navigate back or to home
          Navigator.pop(context);
        } else if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success["message"]),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _officerSVCController.dispose();
    // _emailController.dispose();
    // _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
