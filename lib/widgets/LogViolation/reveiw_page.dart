import 'package:flutter/material.dart';
import 'package:police_app/widgets/LogViolation/buildSummarySection.dart';

class ReviewPage extends StatelessWidget {
  final String? touristName;
  final String? touristId;
  final String? passportNumber;
  final String? country;
  final String? violationType;
  final String? date;
  final String? time;
  final String? location;
  final String? fine;
  final String? officerId;
  final String? officerName;
  final GlobalKey<FormState> formKey;

  const ReviewPage({
    Key? key,
    required this.touristName,
    required this.touristId,
    required this.passportNumber,
    required this.country,
    required this.violationType,
    required this.date,
    required this.time,
    required this.location,
    required this.fine,
    required this.officerId,
    required this.officerName,
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
            Container(
              alignment: Alignment.center,
              child: Text(
                'Review Information',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 24),

            // Tourist Information Summary
            SummarySection(
              title: 'Tourist Information',
              items: [
                {'label': 'Name', 'value': touristName ?? ''},
                {'label': 'ID', 'value': touristId ?? ''},
                {'label': 'Passport', 'value': passportNumber ?? ''},
                {'label': 'Country', 'value': country ?? ''},
              ],
            ),

            const SizedBox(height: 24),

            // Violation Information Summary
            SummarySection(
              title: 'Violation Details',
              items: [
                {'label': 'Type', 'value': violationType ?? 'Not selected'},
                {'label': 'Date', 'value': date ?? ''},
                {'label': 'Time', 'value': time ?? ''},
                {'label': 'Location', 'value': location ?? ''},
                {'label': 'Fine', 'value': fine ?? ''},
              ],
            ),

            const SizedBox(height: 24),

            // Officer Information Summary
            SummarySection(
              title: 'Officer Details',
              items: [
                {'label': 'ID', 'value': officerId ?? 'Unknown'},
                {'label': 'Name', 'value': officerName ?? 'Unknown Officer'},
              ],
            ),
          ],
        ),
      ),
    );
  }
}
