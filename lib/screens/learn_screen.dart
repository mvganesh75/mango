import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> learnData = [
      {
        'title': 'diseases.powderyMildew'.tr(),
        'symptoms': 'learn.White powdery spots on leaves and buds.'.tr(),
        'treatment': 'learn.Apply sulfur-based fungicides.'.tr(),
        'more': 'learn.Ensure good air circulation and avoid overhead watering.'.tr(),
      },
      {
        'title': 'diseases.anthracnose'.tr(),
        'symptoms': 'learn.Black lesions on fruits and leaves.'.tr(),
        'treatment': 'learn.Use copper-based fungicides.'.tr(),
        'more': 'learn.Remove and destroy infected plant parts.'.tr(),
      },
      {
        'title': 'diseases.bacterialCanker'.tr(),
        'symptoms': 'learn.Gum oozing and black spots.'.tr(),
        'treatment': 'learn.Use antibiotics and prune infected parts.'.tr(),
        'more': 'learn.Disinfect pruning tools after each cut.'.tr(),
      },
      {
        'title': 'diseases.sootyMold'.tr(),
        'symptoms': 'learn.Black, sooty coating on leaves and stems.'.tr(),
        'treatment': 'learn.Control sap-sucking insects and wash off mold.'.tr(),
        'more': 'learn.Improve air flow and reduce humidity.'.tr(),
      },
      {
        'title': 'diseases.dieBack'.tr(),
        'symptoms': 'learn.Twigs and branches die from the tip backward.'.tr(),
        'treatment': 'learn.Prune affected branches and apply fungicide.'.tr(),
        'more': 'learn.Avoid waterlogging and improve soil drainage.'.tr(),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'learn.title'.tr(),
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: learnData.length,
        itemBuilder: (context, index) {
          final item = learnData[index];
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
              ]
            ),
            child: ExpansionTile(
              title: Text(
                item['title']!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              iconColor: Colors.green,
              collapsedIconColor: Colors.green,
              childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              expandedAlignment: Alignment.centerLeft,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('learn.symptoms'.tr(), item['symptoms']!),
                    const SizedBox(height: 10),
                    _buildSection('learn.treatment'.tr(), item['treatment']!),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'learn.more'.tr(),
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800),
                          ),
                          const SizedBox(height: 4),
                          Text(item['more']!, style: const TextStyle(color: Colors.black87)),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(content, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}

