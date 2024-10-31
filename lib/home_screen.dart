import 'package:earnings_tracker/api_service.dart';
import 'package:earnings_tracker/graph_page.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _tickerController = TextEditingController();

  List<dynamic> _earningsData = [];
  bool _isNavigating = false;

  /// Handles API call and navigation to GraphPage
  Future<void> _handleEarningsDataFetch() async {
    String ticker = _tickerController.text.trim();
    if (ticker.isEmpty) {
      _showSnackbar('Please enter a ticker.');
      return;
    }

    setState(() => _isNavigating = true);

    try {
      _earningsData = await _apiService.fetchEarningsCalendar(ticker);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GraphPage(
            ticker: ticker,
            earningsData: _earningsData,
          ),
        ),
      );
    } catch (e) {
      _showSnackbar('Failed to load earnings data: $e');
    } finally {
      setState(() => _isNavigating = false);
    }
  }

  /// Displays a Snackbar with the given message
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Earnings Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _tickerController,
                decoration: const InputDecoration(
                  labelText: 'Enter Ticker',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isNavigating ? null : _handleEarningsDataFetch,
              child: const Text(
                'View Earnings Graph',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
