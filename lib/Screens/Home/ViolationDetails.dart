import 'package:flutter/material.dart';
import 'package:police_app/Providers/ViolationProvider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Add this dependency for date formatting

class ViolationDetailsScreen extends StatefulWidget {
  final String violationId;

  const ViolationDetailsScreen({super.key, required this.violationId});

  @override
  State<ViolationDetailsScreen> createState() => _ViolationDetailsScreenState();
}

class _ViolationDetailsScreenState extends State<ViolationDetailsScreen> {
  Map<String, dynamic>? _violation;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchViolation();
    });
  }

  Future<void> _fetchViolation() async {
    final violationProvider =
        Provider.of<ViolationProvider>(context, listen: false);
    final violation =
        await violationProvider.getViolationById(widget.violationId);

    setState(() {
      _isLoading = false;
      if (violation != null) {
        _violation = violation;
      } else {
        _error = violationProvider.error;
      }
    });
  }

  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';

    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';

    try {
      // Handle different date formats
      DateTime dateTime;
      if (dateString.contains('T')) {
        dateTime = DateTime.parse(dateString);
      } else {
        // Assuming format is yyyy-MM-dd
        final parts = dateString.split('-');
        dateTime = DateTime(
            int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      }
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchViolation,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading violation details...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchViolation,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_violation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.find_in_page, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Violation not found', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildTouristCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildViolationCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildOfficerCard(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reference #${_violation!['referenceNumber'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Created: ${_formatDateTime(_violation!['timestamp'])}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTouristCard() {
    final tourist = _violation!['tourist'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Color.fromARGB(255, 63, 92, 221).withOpacity(0.3),
                  child: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tourist Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoTile('Name', tourist['name'] ?? 'N/A', Icons.person),
            _buildInfoTile(
                'Passport', tourist['passport'] ?? 'N/A', Icons.credit_card),
            _buildInfoTile('Country', tourist['country'] ?? 'N/A', Icons.flag),
            if (tourist['id'] != null)
              _buildInfoTile('ID Number', tourist['id'], Icons.badge),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationCard() {
    final violation = _violation!['violation'];
    final fine = violation['fine']?.toString() ?? 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.error.withOpacity(0.2),
                  child: Icon(
                    Icons.gavel,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Violation Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoTile('Type', violation['type'] ?? 'N/A', Icons.category),
            _buildInfoTile(
                'Date', _formatDate(violation['date']), Icons.calendar_today),
            _buildInfoTile(
                'Time', violation['time'] ?? 'N/A', Icons.access_time),
            _buildInfoTile(
                'Location', violation['location'] ?? 'N/A', Icons.location_on),
            _buildInfoTile('Fine', fine, Icons.monetization_on),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficerCard() {
    final officer = _violation!['officer'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                       Color.fromARGB(255, 86, 216, 127).withOpacity(0.3),
                  child: Icon(
                    Icons.security,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Officer Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoTile('SVC', officer['id'] ?? 'N/A', Icons.badge),
            _buildInfoTile('Name', officer['name'] ?? 'N/A', Icons.person),
            if (officer['station'] != null)
              _buildInfoTile(
                  'Station', officer['station'], Icons.location_city),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
