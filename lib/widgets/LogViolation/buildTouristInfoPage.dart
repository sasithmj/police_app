import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TouristInfoPage extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController passportController;
  final TextEditingController countryController;
  final TextEditingController idController;

  final bool isLoading;
  final GlobalKey<FormState> formKey;

  const TouristInfoPage({
    super.key,
    required this.nameController,
    required this.passportController,
    required this.countryController,
    required this.idController,
    required this.isLoading,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Container(
            //   alignment: Alignment.center,
            //   child: Text(
            //     'Tourist Information',
            //     style: Theme.of(context).textTheme.headlineSmall,
            //   ),
            // ),
            const SizedBox(height: 24),

            // Tourist Name
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tourist Name',
                prefixIcon: Icon(Icons.person),
              ),
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter tourist name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: 'Tourist ID',
                prefixIcon: Icon(Icons.article),
              ),
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter tourist ID';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Passport Number
            TextFormField(
              controller: passportController,
              decoration: const InputDecoration(
                labelText: 'Passport Number',
                prefixIcon: Icon(Icons.airplane_ticket_rounded),
              ),
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passport number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Nationality
            TextFormField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.flag),
              ),
              enabled: !isLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter country';
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
