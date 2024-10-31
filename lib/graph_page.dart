import 'package:earnings_tracker/transcript_page.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'api_service.dart';

/// A page that displays earnings data in a line chart format.
class GraphPage extends StatefulWidget {
  final String ticker;
  final List<dynamic> earningsData;

  const GraphPage({super.key, required this.ticker, required this.earningsData});

  @override
  _GraphPageState createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  final ApiService _apiService = ApiService();
  String _companyName = '';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    fetchCompanyName();
  }

  /// Fetches the company name using the ticker symbol.
  Future<void> fetchCompanyName() async {
    try {
      final name = await _apiService.fetchCompanyName(widget.ticker);
      setState(() {
        _companyName = name;
      });
    } catch (e) {
      print('Error fetching company name: $e');
      setState(() {
        _companyName = 'Unknown Company'; // Fallback in case of error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings for \n$_companyName',
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
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(isEstimate: true),
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.blue,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: _getSpots(isEstimate: false),
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.red,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineTouchData: LineTouchData(
                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (_isNavigating) return;
                      if (touchResponse != null && touchResponse.lineBarSpots != null) {
                        final spot = touchResponse.lineBarSpots!.first;
                        final priceDate = widget.earningsData[spot.x.toInt()]['pricedate'];

                        final quarter = _getQuarterFromDate(priceDate);
                        final year = _getYearFromDate(priceDate);
                        _isNavigating = true;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TranscriptPage(
                              ticker: widget.ticker,
                              priceDate: priceDate,
                              quarter: quarter,
                              year: year,
                              companyName: _companyName,
                            ),
                          ),
                        ).then((_) {
                          _isNavigating = false;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Generates the spots for the line chart based on whether they are estimates or actual values.
  List<FlSpot> _getSpots({required bool isEstimate}) {
    return List<FlSpot>.generate(
      widget.earningsData.length,
      (index) => FlSpot(
        index.toDouble(),
        isEstimate
            ? (widget.earningsData[index]['estimated_eps'] ?? 0.0).toDouble()
            : (widget.earningsData[index]['actual_eps'] ?? 0.0).toDouble(),
      ),
    );
  }

  /// Determines the quarter based on the given date string.
  String _getQuarterFromDate(String date) {
    final month = int.parse(date.split('-')[1]);
    if (month >= 1 && month <= 3) return '1';
    if (month >= 4 && month <= 6) return '2';
    if (month >= 7 && month <= 9) return '3';
    return '4'; // October to December
  }

  /// Extracts the year from the given date string.
  String _getYearFromDate(String date) {
    return date.split('-')[0];
  }
}
