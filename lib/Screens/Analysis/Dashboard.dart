import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:police_app/Providers/ViolationProvider.dart';
import 'package:police_app/theme/AppColors.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class ViolationAnalysisDashboard extends StatefulWidget {
  const ViolationAnalysisDashboard({Key? key}) : super(key: key);

  @override
  _ViolationAnalysisDashboardState createState() =>
      _ViolationAnalysisDashboardState();
}

class _ViolationAnalysisDashboardState
    extends State<ViolationAnalysisDashboard> {
  // Selected month and year for filtering
  DateTime selectedDate = DateTime.now();
  Map<String, int> violationTypeCount = {};
  Map<String, int> violationLocationCount = {};
  Map<int, int> dailyViolations = {};
  int totalViolations = 0;

  @override
  void initState() {
    super.initState();
    fetchViolations();
  }

  Future<void> fetchViolations() async {
    final violationProvider =
        Provider.of<ViolationProvider>(context, listen: false);

    // Format the selected date for filtering
    String monthYear = DateFormat('yyyy-MM').format(selectedDate);
    print('Filtering for month-year: $monthYear');

    // Clear previous data to avoid mixing results
    violationProvider.clearViolations();

    // Fetch all violations without date filter
    await violationProvider.getViolations();

    // After fetching, filter and analyze the data
    if (mounted) {
      setState(() {
        // Filter the violations for the selected month before analyzing
        final filteredViolations =
            violationProvider.violations.where((violation) {
          String dateStr = violation['violation']['date'] ?? '';
          try {
            // Check if the date starts with our year-month pattern
            return dateStr.startsWith(monthYear);
          } catch (e) {
            print('Error parsing date: $dateStr');
            return false;
          }
        }).toList();

        // Analyze only the filtered violations
        _analyzeViolations(filteredViolations);
      });
    }
  }

  void _analyzeViolations(List<Map<String, dynamic>> violations) {
    // Reset counters
    violationTypeCount = {};
    violationLocationCount = {};
    dailyViolations = {};
    totalViolations = violations.length;

    // Initialize all days with zero
    int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      dailyViolations[i] = 0;
    }

    // Count violations by type, location, and day
    for (var violation in violations) {
      // Count by type
      String type = violation['violation']['type'] ?? 'Unknown';
      violationTypeCount[type] = (violationTypeCount[type] ?? 0) + 1;

      // Count by location
      String location = violation['violation']['location'] ?? 'Unknown';
      violationLocationCount[location] =
          (violationLocationCount[location] ?? 0) + 1;

      // Count by day
      String dateStr = violation['violation']['date'] ?? '';
      try {
        DateTime violationDate = DateFormat('yyyy-MM-dd').parse(dateStr);
        if (violationDate.month == selectedDate.month &&
            violationDate.year == selectedDate.year) {
          dailyViolations[violationDate.day] =
              (dailyViolations[violationDate.day] ?? 0) + 1;
        }
      } catch (e) {
        // Handle date parsing errors if any
        print('Error parsing date: $dateStr');
      }
    }
  }

  // Month picker
  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null) {
      setState(() {
        selectedDate = DateTime(picked.year, picked.month);
      });
      fetchViolations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final violationProvider = Provider.of<ViolationProvider>(context);
    final bool isLoading = violationProvider.isLoading;
    final List<Map<String, dynamic>> violations = violationProvider.violations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Violation Analysis Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchViolations,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : violations.isEmpty
              ? const Center(
                  child: Text('No violations found for the selected month'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary card
                      Card(
                        elevation: 1, // Added elevation for better visibility
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(20), // Increased padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Summary - ${DateFormat('MMMM yyyy').format(selectedDate)}',
                                    style: const TextStyle(
                                      fontSize: 20, // Increased font size
                                      fontWeight: FontWeight.bold,
                                      color: AppColors
                                          .darkBlue, // Added color for emphasis
                                    ),
                                  ),
                                  // Added icon
                                ],
                              ),
                              const SizedBox(height: 16), // Increased spacing
                              const Divider(), // Added divider for visual separation
                              const SizedBox(height: 8),
                              // Using more descriptive layouts for each statistic
                              Row(
                                children: [
                                  const Icon(Icons.warning,
                                      color: Colors.orange),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Total Violations:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$totalViolations',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.category,
                                      color: Colors.purple),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Types of Violations:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${violationTypeCount.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      color: Colors.green),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Locations with Violations:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${violationLocationCount.length}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              // Error handling with better visual feedback
                              if (violationProvider.error.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.red.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: Colors.red),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Error: ${violationProvider.error}',
                                          style: const TextStyle(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Violation Types Chart
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Violations by Type',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.calendar_month),
                                    label: Text(DateFormat('MMMM yyyy')
                                        .format(selectedDate)),
                                    onPressed: _selectMonth,
                                    style: TextButton.styleFrom(
                                        foregroundColor: AppColors.darkBlue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildViolationTypePieChart(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Violation Locations Chart
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Violations by Location',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 300,
                                child: _buildViolationLocationBarChart(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Daily violations chart
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Violations in ${DateFormat('MMMM yyyy').format(selectedDate)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 300,
                                child: _buildDailyViolationsLineChart(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Status Distribution Chart
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildViolationTypePieChart() {
    if (violationTypeCount.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Generate chart sections and legend data
    List<PieChartSectionData> sections = [];
    Map<String, Color> typeColors = {};

    // Assign colors to each violation type
    List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];

    int colorIndex = 0;
    violationTypeCount.forEach((type, count) {
      Color color = colors[colorIndex % colors.length];
      typeColors[type] = color;
      colorIndex++;

      double percentage = count / totalViolations * 100;
      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    // Calculate an appropriate height for the chart based on legend items
    // Set a minimum height for the chart area
    final int chartHeight = 200;
    // Each legend item takes approximately 28 pixels (padding + height)
    final int legendHeight = violationTypeCount.length * 28;
    // Total height with some buffer space
    final int totalHeight = chartHeight + legendHeight + 20;

    return SizedBox(
      height: totalHeight.toDouble(),
      child: Column(
        children: [
          // Pie chart with fixed height
          SizedBox(
            height: chartHeight.toDouble(),
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          // Scrollable legend that takes remaining space
          const SizedBox(
            height: 15,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: violationTypeCount.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          color: typeColors[entry.key],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${entry.key}: ${entry.value} (${(entry.value / totalViolations * 100).toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationLocationBarChart() {
    if (violationLocationCount.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // Sort locations by count for better visualization
    var sortedLocations = Map.fromEntries(
        violationLocationCount.entries.toList()
          ..sort((e1, e2) => e2.value.compareTo(e1.value)));

    // Limit to top 10 locations if there are many
    if (sortedLocations.length > 10) {
      var top10 = sortedLocations.entries.take(10).toList();
      sortedLocations = Map.fromEntries(top10);
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            sortedLocations.values.reduce((a, b) => a > b ? a : b).toDouble() *
                1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String locationName = sortedLocations.keys.elementAt(groupIndex);
              int count = sortedLocations.values.elementAt(groupIndex);
              double percentage = count / totalViolations * 100;
              return BarTooltipItem(
                '$locationName\n$count violations (${percentage.toStringAsFixed(1)}%)',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= sortedLocations.length)
                  return const Text('');
                String text = sortedLocations.keys.elementAt(value.toInt());
                int count = sortedLocations.values.elementAt(value.toInt());
                double percentage = count / totalViolations * 100;

                // Truncate long location names
                if (text.length > 10) {
                  text = text.substring(0, 7) + '...';
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '(${percentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
              reservedSize: 60, // Increased to accommodate two lines of text
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barGroups: List.generate(sortedLocations.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: sortedLocations.values.elementAt(index).toDouble(),
                color: Colors.blue.shade300,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDailyViolationsLineChart() {
    if (dailyViolations.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    List<FlSpot> spots = [];
    dailyViolations.forEach((day, count) {
      spots.add(FlSpot(day.toDouble(), count.toDouble()));
    });

    int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    int maxViolationsPerDay =
        dailyViolations.values.fold(0, (max, value) => math.max(max, value));

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 5,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value % 5 == 0 || value == 1 || value == daysInMonth) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value == value.roundToDouble() &&
                    value >= 0 &&
                    value <= maxViolationsPerDay) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black12),
        ),
        minX: 1,
        maxX: daysInMonth.toDouble(),
        minY: 0,
        maxY: maxViolationsPerDay.toDouble() + 1,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
