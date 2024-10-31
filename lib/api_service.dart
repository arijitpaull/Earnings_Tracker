import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for fetching financial data from the API.
class ApiService {
  final String apiKey = 'fMb4XQILLUEdnG+ol6Q/hA==W1Azl5jmnxuuRj5c';
  final String baseUrl = 'https://api.api-ninjas.com/v1';

  /// Fetches the company name for a given [ticker].
  /// Throws an [Exception] if unable to fetch data.
  Future<String> fetchCompanyName(String ticker) async {
    final url = Uri.parse('$baseUrl/marketcap?ticker=$ticker');
    final response = await _get(url);

    final data = json.decode(response.body);
    if (data['name'] != null) {
      return data['name'];
    } else {
      throw Exception('Company name not found for ticker: $ticker');
    }
  }

  /// Fetches earnings calendar data for a given [ticker].
  /// Returns a list of earnings data or throws an [Exception] on failure.
  Future<List<dynamic>> fetchEarningsCalendar(String ticker) async {
    final url = Uri.parse('$baseUrl/earningscalendar?ticker=$ticker');
    final response = await _get(url);

    final data = json.decode(response.body);
    if (data.isNotEmpty) {
      return data;
    } else {
      throw Exception('No earnings data found for ticker: $ticker');
    }
  }

  /// Fetches the earnings transcript for a given [ticker], [quarter], and [year].
  /// Returns a [String] transcript or throws an [Exception] on failure.
  Future<String> fetchEarningsTranscript(String ticker, String quarter, String year) async {
    final url = Uri.parse('$baseUrl/earningstranscript?ticker=$ticker&year=$year&quarter=$quarter');
    final response = await _get(url);

    final data = json.decode(response.body);
    if (data['transcript'] != null) {
      return data['transcript'];
    } else {
      throw Exception('Earnings transcript not available for $ticker, Q$quarter $year');
    }
  }

  /// Helper method to send a GET request to the specified [url].
  /// Adds headers and handles common errors.
  Future<http.Response> _get(Uri url) async {
    final response = await http.get(url, headers: {'X-Api-Key': apiKey});

    if (response.statusCode != 200) {
      throw Exception('Failed to load data: ${response.statusCode} - ${response.reasonPhrase}');
    }

    return response;
  }
}
