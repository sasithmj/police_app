import 'package:flutter/material.dart';

class ViolationDetailsPage extends StatelessWidget {
  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController fineController;
  final String? selectedViolationType;
  final String? selectedLocation;
  final List<String> violationTypes;
  final List<String> locations;
  final Function(String?) onViolationTypeChanged;
  final Function(String?) onLocationChanged;
  final Function(BuildContext) selectDate;
  final Function(BuildContext) selectTime;
  final bool isLoading;
  final GlobalKey<FormState> formKey;

  const ViolationDetailsPage({
    Key? key,
    required this.dateController,
    required this.timeController,
    required this.fineController,
    required this.selectedViolationType,
    required this.selectedLocation,
    required this.violationTypes,
    required this.locations,
    required this.onViolationTypeChanged,
    required this.onLocationChanged,
    required this.selectDate,
    required this.selectTime,
    required this.isLoading,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'Violation Details',
            //   style: Theme.of(context).textTheme.headlineSmall,
            // ),
            const SizedBox(height: 24),

            // Violation Type
            DropdownButtonFormField<String>(
              value: selectedViolationType,
              decoration: const InputDecoration(
                labelText: 'Violation Type',
                prefixIcon: Icon(Icons.warning),
              ),
              items: violationTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: isLoading ? null : onViolationTypeChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select violation type';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Date
            TextFormField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: isLoading ? null : () => selectDate(context),
                ),
              ),
              readOnly: true,
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select date';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Time
            TextFormField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Time',
                prefixIcon: const Icon(Icons.access_time),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.more_time),
                  onPressed: isLoading ? null : () => selectTime(context),
                ),
              ),
              readOnly: true,
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select time';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Location
            DropdownButtonFormField<String>(
              value: selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_pin),
              ),
              items: locations.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: isLoading ? null : onLocationChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select Location';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location
            TextFormField(
              controller: fineController,
              decoration: const InputDecoration(
                labelText: 'Fine',
                prefixIcon: Icon(Icons.attach_money_outlined),
              ),
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Fine';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
