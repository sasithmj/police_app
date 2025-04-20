import 'package:flutter/material.dart';
import 'package:police_app/Providers/RuleProvider.dart';
import 'package:police_app/widgets/Audio/AudioPlayerWidget%20.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class RuleDetailScreen extends StatelessWidget {
  final TrafficRule rule;
  final String selectedLanguage;

  const RuleDetailScreen({
    Key? key,
    required this.rule,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rule ${rule.ruleNumber}'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // Share functionality could be added here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rule title with number
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    foregroundColor: Theme.of(context).colorScheme.onTertiary,
                    radius: 24,
                    child: Text(
                      '${rule.ruleNumber}',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      rule.title[selectedLanguage] ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Fine amount card
            Card(
              color:
                  Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Fine Amount: Rs. ${rule.fineAmount}.00',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Rule description
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
                ),
              ),
              child: MarkdownBody(
                data: rule.description[selectedLanguage] ?? '',
                styleSheet:
                    MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                  p: Theme.of(context).textTheme.bodyLarge,
                  strong: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Voice recording section
            Text(
              'Audio Explanation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),

            // New enhanced AudioPlayerWidget
            AudioPlayerWidget(ruleNumber: rule.ruleNumber),

            // Additional information section - if needed
            SizedBox(height: 24),
            // _buildAdditionalInfo(context),
          ],
        ),
      ),
      // Add floating action button for quick access to primary audio
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Scroll to audio section
      //     Scrollable.ensureVisible(
      //       context.findRenderObject()!,
      //       alignment: 0.8,
      //       duration: Duration(milliseconds: 300),
      //     );
      //     // You could also implement direct audio playback here
      //   },
      //   child: Icon(Icons.volume_up),
      //   tooltip: 'Listen to rule explanation',
      // ),
    );
  }
}
