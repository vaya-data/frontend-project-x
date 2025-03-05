import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPitchScreen extends StatefulWidget {
  @override
  _AddPitchScreenState createState() => _AddPitchScreenState();
}

class _AddPitchScreenState extends State<AddPitchScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pitchNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _gmapLinkController = TextEditingController();
  final TextEditingController _othersController = TextEditingController();

  String _selectedType = 'outdoor'; //  Default type set to 'indoor'

  // Features checkboxes
  Map<String, bool> features = {
    'parking': false,
    'showers': false,
    'lockers': false,
    'beach': false,
    'swimming_pool': false,
    'water_fountain': false,
    'bar': false,
  };

  // List to store additional Other Features and initially as an EMPTY list now
  List<String> _otherFeaturesList = [];

  // Function to add an "Other Feature"
  void _addOtherFeature() {
    String feature = _othersController.text.trim();
    if (feature.isNotEmpty && !_otherFeaturesList.contains(feature)) {
      setState(() {
        _otherFeaturesList.add(feature);
        _othersController.clear();
      });
    }
  }

  // Function to remove an "Other Feature"
  void _removeOtherFeature(String feature) {
    setState(() {
      _otherFeaturesList.remove(feature);
    });
  }

  Future<void> _submitPitch() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> pitchData = {
        "pitchname": _pitchNameController.text,
        "address": _addressController.text,
        "gmaplink": _gmapLinkController.text,
        "type": _selectedType,
        "features": {
          ...features,
          "others": _otherFeaturesList, //  Now stores dynamically added items
        },
      };

      final response = await http.post(
        Uri.parse("http://10.0.2.2:5001/project-x-384a0/us-central1/api/pitch/addpitch"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(pitchData),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pitch added successfully!")),
        );
        _formKey.currentState!.reset();
        _othersController.clear();
        setState(() {
          _otherFeaturesList.clear(); //  Reset other features list
          features.updateAll((key, value) => false); //  Reset checkboxes
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add pitch!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Pitch")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _pitchNameController,
                  decoration: InputDecoration(labelText: "Pitch Name"),
                  validator: (value) => value!.isEmpty ? "Enter pitch name" : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: "Address"),
                  validator: (value) => value!.isEmpty ? "Enter address" : null,
                ),
                TextFormField(
                  controller: _gmapLinkController,
                  decoration: InputDecoration(labelText: "Google Map Link"),
                  validator: (value) => value!.isEmpty ? "Enter Google Map link" : null,
                ),
                DropdownButtonFormField(
                  value: _selectedType,
                  decoration: InputDecoration(labelText: "Pitch Type"),
                  items: ['outdoor', 'indoor'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value.toString();
                    });
                  },
                ),
                SizedBox(height: 10),
                Text("Features", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ...features.keys.map((feature) {
                  return CheckboxListTile(
                    title: Text(feature.replaceAll("_", " ").toUpperCase()),
                    value: features[feature],
                    onChanged: (bool? value) {
                      setState(() {
                        features[feature] = value!;
                      });
                    },
                  );
                }).toList(),
                SizedBox(height: 10),

                // Other Features Section
                Text("Other Features", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _othersController,
                        decoration: InputDecoration(labelText: "Enter feature"),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: _addOtherFeature,
                    ),
                  ],
                ),

                // Show List of Added Other Features
                if (_otherFeaturesList.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _otherFeaturesList.map((feature) {
                      return ListTile(
                        title: Text(feature),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _removeOtherFeature(feature),
                        ),
                      );
                    }).toList(),
                  ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitPitch,
                  child: Text("Submit"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
