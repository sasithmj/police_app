// lib/services/rule_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';

class RuleProvider {
  Future<List<TrafficRule>> getRules() async {
    // In a real app, you might load this from an API or a database
    final String response =
        await rootBundle.loadString('assets/new.json');
    final List<dynamic> jsonData = json.decode(response);

    return jsonData.map((data) => TrafficRule.fromJson(data)).toList();
  }
}

class TrafficRule {
  final int ruleNumber;
  final Map<String, String> title;
  final Map<String, String> description;
  final int fineAmount;

  TrafficRule({
    required this.ruleNumber,
    required this.title,
    required this.description,
    required this.fineAmount,
  });

  factory TrafficRule.fromJson(Map<String, dynamic> json) {
    return TrafficRule(
      ruleNumber: json['rule_number'],
      title: Map<String, String>.from(json['title']),
      description: Map<String, String>.from(json['description']),
      fineAmount: json['fine_amount'],
    );
  }
}
