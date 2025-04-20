import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:police_app/Providers/ViolationProvider.dart';
import 'package:police_app/theme/AppColors.dart';
import 'package:police_app/widgets/LogViolation/buildTouristInfoPage.dart';
import 'package:police_app/widgets/LogViolation/buildViolationDetailsPage.dart';
import 'package:police_app/widgets/LogViolation/reveiw_page.dart';
import 'package:provider/provider.dart';
import 'package:police_app/Providers/AuthProvider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class LogViolationWizard extends StatefulWidget {
  const LogViolationWizard({Key? key}) : super(key: key);

  @override
  State<LogViolationWizard> createState() => _LogViolationWizardState();
}

class _LogViolationWizardState extends State<LogViolationWizard> {
  // Page controller for the wizard
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Form keys for each step
  final _touristFormKey = GlobalKey<FormState>();
  final _violationFormKey = GlobalKey<FormState>();
  final _reviewFormKey = GlobalKey<FormState>();

  // Tourist details controllers
  final _touristNameController = TextEditingController();
  final _passportNumberController = TextEditingController();
  final _countryController = TextEditingController();
  final _idController = TextEditingController();

  // Violation details controllers
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  // final _locationController = TextEditingController();
  final _fineController = TextEditingController();

  // Officer details - will be pre-populated from authentication
  String? _officerId;
  String? _officerName;

  List<String> violationTypes = [
    'Speeding',
    'Driving without valid license',
    'Illegal parking',
    'Failure to wear helmet',
    'Running red light',
    'Using mobile phone while driving',
    'Driving under influence',
    'Improper lane usage',
    'Other'
  ];
  List<String> Locations = [
    'Colombo Central',
    'Kandy',
    'Galle',
    'Jaffna',
    'Batticaloa',
    'Negombo',
    'Anuradhapura',
    'Matara',
  ];

  String? _selectedViolationType;
  String? _selectedLocation;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    // Set default date
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set the time text here instead, after context is fully available
    _timeController.text = _selectedTime.format(context);
    _loadOfficerDetails();
  }

  void _loadOfficerDetails() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _officerId = authProvider.officerId ?? 'Unknown';
      _officerName = authProvider.officerName ?? 'Unknown Officer';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2022),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  void _nextPage() {
    switch (_currentPage) {
      case 0:
        if (_touristFormKey.currentState!.validate()) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
      case 1:
        if (_violationFormKey.currentState!.validate()) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitViolation() async {
    if (_reviewFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create violation data object
        final violationData = {
          'tourist': {
            'name': _touristNameController.text,
            'passport': _passportNumberController.text,
            'country': _countryController.text,
            'id': _idController.text,
          },
          'violation': {
            'type': _selectedViolationType,
            'date': _dateController.text,
            'time': _timeController.text,
            'location': _selectedLocation,
            'fine': _fineController.text,
          },
          'officer': {
            'id': _officerId,
            'name': _officerName,
          },
          'timestamp': DateTime.now().toIso8601String(),
        };
        final violationProvider =
            Provider.of<ViolationProvider>(context, listen: false);
        final success = await violationProvider.createViolation(violationData);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Violation reported successfully')),
          );
          Navigator.of(context).pop();
        }
        // Submit data to your backend service
        // This is a placeholder - replace with your actual API call

        // Show success message and navigate back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Violation logged successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Wait for snackbar to show before navigating back
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } catch (e) {
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error logging violation: ${e.toString()}'),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log Traffic Violation',
          style: TextStyle(color: AppColors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onTertiary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepIndicator(0, 'Tourist'),
                  _buildStepSeparator(),
                  _buildStepIndicator(1, 'Violation'),
                  _buildStepSeparator(),
                  _buildStepIndicator(2, 'Review'),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // Use the new modular components
                  TouristInfoPage(
                    nameController: _touristNameController,
                    passportController: _passportNumberController,
                    countryController: _countryController,
                    idController: _idController,
                    isLoading: _isLoading,
                    formKey: _touristFormKey,
                  ),
                  ViolationDetailsPage(
                    dateController: _dateController,
                    timeController: _timeController,
                    selectedLocation: _selectedLocation,
                    fineController: _fineController,
                    selectedViolationType: _selectedViolationType,
                    violationTypes: violationTypes,
                    locations: Locations,
                    onViolationTypeChanged: (newValue) {
                      setState(() {
                        _selectedViolationType = newValue;
                      });
                    },
                    onLocationChanged: (newValue) {
                      setState(() {
                        _selectedLocation = newValue;
                      });
                    },
                    selectDate: _selectDate,
                    selectTime: _selectTime,
                    isLoading: _isLoading,
                    formKey: _violationFormKey,
                  ),
                  ReviewPage(
                    touristName: _touristNameController.text,
                    passportNumber: _passportNumberController.text,
                    country: _countryController.text,
                    touristId: _idController.text,
                    violationType: _selectedViolationType,
                    date: _dateController.text,
                    time: _timeController.text,
                    location: _selectedLocation,
                    fine: _fineController.text,
                    officerId: _officerId,
                    officerName: _officerName,
                    formKey: _reviewFormKey,
                  ),
                ],
              ),
            ),
// Progress indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
            // Navigation buttons
            Container(
              decoration: const BoxDecoration(
                color: Colors.white38,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _previousPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox(width: 80),
                  _currentPage < 2
                      ? ElevatedButton(
                          onPressed: _isLoading ? null : _nextPage,
                          child: const Text('Next'),
                        )
                      : ElevatedButton(
                          onPressed: _isLoading ? null : _submitViolation,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Submit'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final bool isActive = _currentPage >= step;

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color:
                isActive ? Theme.of(context).colorScheme.primary : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepSeparator() {
    return Container(
      width: 40,
      height: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 20),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _touristNameController.dispose();
    _passportNumberController.dispose();
    _countryController.dispose();
    _idController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _fineController.dispose();
    super.dispose();
  }
}
