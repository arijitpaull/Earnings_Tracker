import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'api_service.dart';

/// A page that displays the earnings transcript for a specific company.
class TranscriptPage extends StatefulWidget {
  final String ticker;
  final String priceDate;
  final String quarter;
  final String year;
  final String companyName;

  const TranscriptPage({
    super.key,
    required this.ticker,
    required this.priceDate,
    required this.quarter,
    required this.year,
    required this.companyName,
  });

  @override
  _TranscriptPageState createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> {
  final ApiService _apiService = ApiService();
  String _transcript = '';

  @override
  void initState() {
    super.initState();
    fetchTranscript();
  }

  /// Fetches the earnings transcript and updates the state.
  Future<void> fetchTranscript() async {
    try {
      final data = await _apiService.fetchEarningsTranscript(
        widget.ticker,
        widget.quarter,
        widget.year,
      );
      setState(() {
        _transcript = data;
      });
    } catch (e) {
      setState(() {
        _transcript = 'Error loading transcript: $e'; // Error message for UI
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.companyName} \n ${widget.priceDate} (Q${widget.quarter})',
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: _transcript.isNotEmpty
              ? MarkdownBody(data: _transcript, selectable: true)
              : const Center(child: CircularProgressIndicator()), // Loading indicator
        ),
      ),
    );
  }
}
