import 'package:flutter/foundation.dart';

class QuoteDecision {
  const QuoteDecision({
    required this.status,
    required this.approvalStatus,
    required this.approvalDate,
  });

  final String status;

  final String approvalStatus;

  final String approvalDate;
}

class QuoteDecisionService {
  QuoteDecisionService._();

  static final ValueNotifier<int> changes = ValueNotifier<int>(0);
  static final Map<String, QuoteDecision> _decisions = {};

  static String _two(int n) => n.toString().padLeft(2, '0');

  static void apply(String quoteNumber, {required bool approved}) {
    final number = quoteNumber.trim();
    if (number.isEmpty) return;

    final now = DateTime.now();

    _decisions[number] = QuoteDecision(
      status: approved ? 'مقبول' : 'مرفوض',
      approvalStatus: approved ? 'معتمد' : 'مرفوض',
      approvalDate: '${now.year}-${_two(now.month)}-${_two(now.day)}',
    );

    changes.value++;
  }

  static Map<String, dynamic> overlay(Map<String, dynamic> quote) {
    final d = _decisions[(quote['quoteNumber'] ?? '').toString().trim()];
    if (d == null) return quote;

    return {
      ...quote,
      'status': d.status,
      'approvalStatus': d.approvalStatus,
      'approvalDate': d.approvalDate,
    };
  }
}