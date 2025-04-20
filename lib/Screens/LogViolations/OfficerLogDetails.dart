import 'package:flutter/material.dart';
import 'package:police_app/theme/AppColors.dart';
import 'package:police_app/Providers/AuthProvider.dart';
import 'package:police_app/Providers/ViolationProvider.dart';
import 'package:police_app/Screens/Home/ViolationDetails.dart';
import 'package:provider/provider.dart';

class LoggedViolationsScreen extends StatefulWidget {
  const LoggedViolationsScreen({super.key});

  @override
  State<LoggedViolationsScreen> createState() => _LoggedViolationsScreenState();
}

class _LoggedViolationsScreenState extends State<LoggedViolationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchViolations();
    });
  }

  Future<void> _fetchViolations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final violationProvider =
        Provider.of<ViolationProvider>(context, listen: false);
    await violationProvider.getViolationsByOfficer(authProvider.officerId);
    if (violationProvider.error.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${violationProvider.error}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Logged Violations',
          style: TextStyle(
            color: AppColors.darkBlue,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 249, 249, 249),
        iconTheme: const IconThemeData(color: AppColors.darkBlue),
      ),
      body: Consumer<ViolationProvider>(
        builder: (context, violationProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Violations Logged by You',
                //   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //         fontWeight: FontWeight.bold,
                //       ),
                // ),
                const SizedBox(height: 16),
                Expanded(
                  child: violationProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : violationProvider.error.isNotEmpty
                          ? Center(
                              child: Text('Error: ${violationProvider.error}'))
                          : violationProvider.violations.isEmpty
                              ? const Center(
                                  child: Text('No violations logged'))
                              : ListView.builder(
                                  itemCount:
                                      violationProvider.violations.length,
                                  itemBuilder: (context, index) {
                                    final violation =
                                        violationProvider.violations[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: ListTile(
                                        title: Text(violation['tourist']
                                                ['name'] ??
                                            'Unknown'),
                                        subtitle: Text(
                                          '${violation['violation']['type'] ?? 'N/A'} • ${violation['violation']['date'] ?? 'N/A'}',
                                        ),
                                        trailing:
                                            const Icon(Icons.chevron_right),
                                        onTap: () {
                                          // Navigate to ViolationDetailsScreen
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViolationDetailsScreen(
                                                violationId: violation['_id'],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
