import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class HistoryRecord {
  final String id;
  final String predictedDisease;
  final double confidence;
  final String timestamp;

  HistoryRecord({
    required this.id,
    required this.predictedDisease,
    required this.confidence,
    required this.timestamp,
  });

  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      id: json['id'].toString(), // Adjust based on API structure (sometimes it's '_id')
      predictedDisease: json['predictedDisease'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] ?? '',
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryRecord> _history = [];
  bool _isLoading = true;
  final String _apiUrl = 'http://104.155.149.91:8000/api/history';

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _history = data.map((item) => HistoryRecord.fromJson(item)).toList();
        });
      } else {
        debugPrint('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteRecord(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(Uri.parse('$_apiUrl/delete/$id/'));
        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            _history.removeWhere((item) => item.id == id);
          });
        } else {
          _showError('Failed to delete the record.');
        }
      } catch (e) {
        debugPrint('Delete error: $e');
        _showError('An error occurred while deleting.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _cleanLabel(String label) {
    return label.toLowerCase().replaceAll(' ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'history.title'.tr(),
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _history.isEmpty
              ? Center(
                  child: Text(
                    'history.message'.tr(),
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: const Border(left: BorderSide(color: Colors.green, width: 5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'home.predictedDisease'.tr()}: ${'home.${_cleanLabel(item.predictedDisease)}'.tr()}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Confidence: ${item.confidence.toStringAsFixed(2)}%',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateTime.tryParse(item.timestamp)?.toLocal().toString().split('.')[0] ?? item.timestamp,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _deleteRecord(item.id),
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

