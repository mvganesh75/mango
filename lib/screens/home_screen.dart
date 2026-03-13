import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;
  Map<String, dynamic>? _prediction;
  
  // Use the new server IP provided by user
  final String _apiUrl = 'http://104.155.149.91:8000/api/predict/';

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _prediction = null;
    });

    final pickedFile = await picker.pickImage(source: source, imageQuality: 100);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _image = null;
      _prediction = null;
    });
  }

  Future<void> _handleAnalyse() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _image!.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data is List) {
          data = data.isEmpty ? {} : data[0];
        }

        if (data['prediction'] != null && data['prediction']['label'] != null) {
          setState(() {
            _prediction = data['prediction'];
          });
        } else {
          _showErrorDialog('alerts.apiError'.tr());
        }
      } else {
        _showErrorDialog('alerts.apiError'.tr() + ' (Code: ${response.statusCode})');
      }
    } catch (e) {
      _showErrorDialog('alerts.apiError'.tr());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          )
        ],
      ),
    );
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
          'home.title'.tr(),
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Text(
              'home.uploadPrompt'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            
            // Upload Box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green, width: 2, style: BorderStyle.solid), // Flutter doesn't natively support dotted borders without custom painters/packages
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icon(Icons.image, color: Colors.white),
                    label: Text('buttons.upload'.tr(), style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text('home.or'.tr(), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text('buttons.camera'.tr(), style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),

            if (_image != null) ...[
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_image!, height: 300, width: double.infinity, fit: BoxFit.contain),
              ),
              TextButton(
                onPressed: _removeImage,
                child: Text('home.Remove'.tr(), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAnalyse,
                  child: _isLoading 
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : Text('buttons.analyse'.tr(), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              )
            ],

            if (_prediction != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('home.predictedDisease'.tr(), style: TextStyle(fontSize: 18, color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('home.${_cleanLabel(_prediction!['label'])}'.tr(), style: TextStyle(fontSize: 20, color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text('${'home.Confidence'.tr()}: ${_prediction!['confidence'].toStringAsFixed(2)}%', style: TextStyle(fontSize: 15, color: Colors.grey.shade800)),
                    const SizedBox(height: 15),
                    
                    Text('home.confidenceBreakdown'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    
                    if (_prediction!['confidence_breakdown'] != null)
                      ...(_prediction!['confidence_breakdown'] as Map<String, dynamic>).entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            children: [
                              Icon(Icons.eco, size: 16, color: Colors.green.shade800),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'preddata.${entry.key}'.tr() + ': ${(entry.value * 1.0).toStringAsFixed(2)}%', 
                                  style: TextStyle(color: Colors.grey.shade800)
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 15),
                    Text('home.diseaseInfo'.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 5),
                    Text(
                      'diseases.${_cleanLabel(_prediction!['label'])}'.tr(),
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    )
                  ],
                ),
              )
            ],

            // Static info block
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('home.diseaseInfo'.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  ...['anthracnose', 'powderyMildew', 'bacterialCanker', 'sootyMold', 'dieBack'].map((key) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('home.$key'.tr(), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade800, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('diseases.$key'.tr(), style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 80), // spacing for bottom nav
          ],
        ),
      ),
    );
  }
}

