import 'package:flutter/material.dart';
import 'package:police_app/Providers/RuleProvider.dart';
import 'package:police_app/Screens/Rules/RuleDetails.dart';
import 'package:police_app/theme/AppColors.dart';

class RulesListScreen extends StatefulWidget {
  const RulesListScreen({Key? key}) : super(key: key);

  @override
  State<RulesListScreen> createState() => _RulesListScreenState();
}

class _RulesListScreenState extends State<RulesListScreen> {
  final RuleProvider _ruleService = RuleProvider();
  List<TrafficRule> _rules = [];
  bool _isLoading = true;
  String _selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    try {
      final rules = await _ruleService.getRules();
      setState(() {
        _rules = rules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading rules: ${e.toString()}')),
      );
    }
  }

  void _toggleLanguage() {
    setState(() {
      // Cycle through the three languages
      if (_selectedLanguage == 'en') {
        _selectedLanguage = 'si';
      } else if (_selectedLanguage == 'si') {
        _selectedLanguage = 'ta';
      } else {
        _selectedLanguage = 'en';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traffic Rules'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Center(
              child: Text(
                _selectedLanguage == "en"
                    ? "සිංහල"
                    : _selectedLanguage == "si"
                        ? "தமிழ்"
                        : "ENGLISH",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: _toggleLanguage,
            tooltip: 'Change Language',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _rules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rule = _rules[index];
                return Column(
                  children: [
                    RuleListTile(
                      rule: rule,
                      selectedLanguage: _selectedLanguage,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RuleDetailScreen(
                              rule: rule,
                              selectedLanguage: _selectedLanguage,
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(),
                  ],
                );
              },
            ),
    );
  }
}

class RuleListTile extends StatelessWidget {
  final TrafficRule rule;
  final String selectedLanguage;
  final VoidCallback onTap;

  const RuleListTile({
    Key? key,
    required this.rule,
    required this.selectedLanguage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(12),
      //   side: const BorderSide(
      //     color: AppColors.lightGray,
      //     width: 1,
      //   ),
      // ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    radius: 20,
                    child: Text(
                      '${rule.ruleNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      rule.title[selectedLanguage] ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 56.0),
                child: Text(
                  'Fine: Rs. ${rule.fineAmount.toString()}.00',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
