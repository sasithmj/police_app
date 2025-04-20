import 'package:flutter/material.dart';
import 'package:police_app/Providers/ViolationProvider.dart';
import 'package:police_app/Screens/Home/ViolationDetails.dart';
import 'package:provider/provider.dart';

class RecentViolations extends StatefulWidget {
  const RecentViolations({super.key});

  @override
  State<RecentViolations> createState() => _RecentViolationsState();
}

class _RecentViolationsState extends State<RecentViolations> {
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchViolations();
  }

  Future<void> _fetchViolations() async {
    final violationProvider =
        Provider.of<ViolationProvider>(context, listen: false);
    setState(() => _isLoading = true);
    final success = await violationProvider.getViolations();
    if (!success) {
      setState(() {
        _isLoading = false;
        _error = violationProvider.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load violations: $_error')),
      );
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ViolationProvider>(
      builder: (context, violationProvider, child) {
        final latestViolations = violationProvider.violations
          ..sort((a, b) => DateTime.parse(b['violation']['date'])
              .compareTo(DateTime.parse(a['violation']['date'])));
        final displayViolations = latestViolations.take(10).toList();

        return Container(
          child: Column(
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error.isNotEmpty)
                Center(child: Text('Error: $_error'))
              else if (displayViolations.isEmpty)
                const Center(child: Text('No recent violations found'))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayViolations.length,
                  itemBuilder: (context, index) {
                    final violation = displayViolations[index];
                    final touristName =
                        violation['tourist']['name'] ?? 'Unknown Tourist';
                    final violationType =
                        violation['violation']['type'] ?? 'Unknown Violation';
                    final violationDate = violation['violation']['date'] != null
                        ? DateTime.parse(violation['violation']['date'])
                            .toString()
                            .substring(0, 10)
                        : 'Unknown Date';

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 12), // Fixed 'custom' typo
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          child: Icon(
                            Icons.description,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(touristName),
                        subtitle: Text('$violationType • $violationDate'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViolationDetailsScreen(
                                violationId: violation['_id'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AllViolationsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('View All Violations'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AllViolationsScreen extends StatelessWidget {
  const AllViolationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Violations')),
      body: const Center(child: Text('All Violations List')),
    );
  }
}
