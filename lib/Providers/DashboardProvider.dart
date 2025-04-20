import 'dart:convert';
import 'package:http/http.dart' as http;

class DashboardProvider {
  
  final String baseUrl;

  DashboardProvider({required this.baseUrl});

  // Fetch violations with filters
  Future<Map<String, dynamic>> getViolations({
    String? touristName,
    String? touristPassport,
    String? touristCountry,
    String? violationType,
    String? violationDate,
    String? officerId,
    String? status,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/violations/get'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (touristName != null) 'tourist.name': touristName,
          if (touristPassport != null) 'tourist.passport': touristPassport,
          if (touristCountry != null) 'tourist.country': touristCountry,
          if (violationType != null) 'violation.type': violationType,
          if (violationDate != null)
            'violation.date': {'\$regex': violationDate},
          if (officerId != null) 'officer.id': officerId,
          if (status != null) 'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load violations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching violations: $e');
    }
  }

  // Get violation statistics for dashboard
  Future<Map<String, dynamic>> getViolationStatistics(String monthYear) async {
    try {
      // First get all violations for the month
      final violationsResponse = await getViolations(
        violationDate: monthYear,
      );

      if (violationsResponse['status'] == true) {
        final violations = violationsResponse['violations'];

        // Process statistics
        Map<String, int> typeCount = {};
        Map<String, int> locationCount = {};
        Map<String, int> countryCount = {};
        Map<String, int> dailyCount = {};

        for (var violation in violations) {
          // Count by type
          String type = violation['violation']['type'];
          typeCount[type] = (typeCount[type] ?? 0) + 1;

          // Count by location
          String location = violation['violation']['location'];
          locationCount[location] = (locationCount[location] ?? 0) + 1;

          // Count by tourist country
          String country = violation['tourist']['country'];
          countryCount[country] = (countryCount[country] ?? 0) + 1;

          // Count by day
          String dateStr = violation['violation']['date'];
          try {
            DateTime date = DateTime.parse(dateStr);
            String dayKey = '${date.day}';
            dailyCount[dayKey] = (dailyCount[dayKey] ?? 0) + 1;
          } catch (e) {
            print('Error parsing date: $dateStr');
          }
        }

        return {
          'status': true,
          'totalViolations': violations.length,
          'violationsByType': typeCount,
          'violationsByLocation': locationCount,
          'violationsByCountry': countryCount,
          'violationsByDay': dailyCount,
        };
      } else {
        return {
          'status': false,
          'error': violationsResponse['error'] ?? 'Failed to fetch violations',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'error': 'Error processing statistics: $e',
      };
    }
  }

  // Get top violation types for the last N months (trend analysis)
  Future<Map<String, dynamic>> getViolationTrends(int months) async {
    try {
      Map<String, Map<String, int>> monthlyData = {};
      DateTime now = DateTime.now();

      for (int i = 0; i < months; i++) {
        DateTime targetMonth = DateTime(now.year, now.month - i);
        String monthKey =
            '${targetMonth.year}-${targetMonth.month.toString().padLeft(2, '0')}';

        // Get statistics for this month
        final stats = await getViolationStatistics(monthKey);

        if (stats['status'] == true) {
          monthlyData[monthKey] =
              Map<String, int>.from(stats['violationsByType']);
        }
      }

      return {
        'status': true,
        'trends': monthlyData,
      };
    } catch (e) {
      return {
        'status': false,
        'error': 'Error fetching trends: $e',
      };
    }
  }
}
