import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  final TextEditingController _organizerIdController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _formatController = TextEditingController();

  String _selectedGender = "Any";
  final List<String> _genders = ["Male", "Female", "Any"];

  final List<String> _amenities = ["Parking", "Water Cooler", "Air Conditioning", "Wi-Fi", "Waiting Rooms"];
  final Map<String, bool> _selectedAmenities = {};

  DateTime? _selectedStartTime;
  List<Map<String, dynamic>> _pitchList = [];  // Stores API data
  String? _selectedLocationId; // Selected location ID

  @override
  void initState() {
    super.initState();
    for (var amenity in _amenities) {
      _selectedAmenities[amenity] = false;
    }
    _fetchPitches(); // Fetch pitches when screen loads
  }

  /// Fetch all pitches from API
  Future<void> _fetchPitches() async {
    final Uri url = Uri.parse("http://10.0.2.2:5001/project-x-384a0/us-central1/api/pitch/getpitches");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _pitchList = data.map((pitch) => {
            "id": pitch["id"], // Assuming "id" is the pitch identifier
            "name": pitch["name"], // Assuming "name" is the pitch name
          }).toList();
        });
      } else {
        print("Failed to fetch pitches: ${response.body}");
      }
    } catch (error) {
      print("Error fetching pitches: $error");
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedStartTime = DateTime(
            picked.year, picked.month, picked.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  Future<void> _addGame() async {
    final Uri url = Uri.parse("http://10.0.2.2:5001/project-x-384a0/us-central1/api/game/addgame");

    final gameData = {
      "title": _titleController.text,
      "description": _descriptionController.text,
      "duration": int.tryParse(_durationController.text) ?? 0,
      "maxParticipants": int.tryParse(_maxParticipantsController.text) ?? 0,
      "locationId": _selectedLocationId, // Use selected pitch ID
      "organizerId": _organizerIdController.text,
      "startTime": _selectedStartTime != null ? DateFormat("yyyy-MM-dd HH:mm:ss").format(_selectedStartTime!) : "",
      "status": _statusController.text,
      "format": _formatController.text,
      "gender": _selectedGender,
      "amenities": _selectedAmenities.keys.where((key) => _selectedAmenities[key] == true).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(gameData),
      );

      if (response.statusCode == 201) {
        print("Game added successfully!");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Game added successfully')));
      } else {
        print("Failed to add game: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add game')));
      }
    } catch (error) {
      print("Error: $error");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error connecting to server')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Game')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Game Title')),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              TextField(controller: _durationController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Duration (mins)')),
              TextField(controller: _maxParticipantsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Max Participants')),
              TextField(controller: _organizerIdController, decoration: const InputDecoration(labelText: 'Organizer ID')),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectStartTime(context),
                child: Text(_selectedStartTime == null ? 'Select Start Time' : DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedStartTime!)),
              ),

              TextField(controller: _statusController, decoration: const InputDecoration(labelText: 'Status')),
              TextField(controller: _formatController, decoration: const InputDecoration(labelText: 'Format')),

              const SizedBox(height: 16),
              const Text("Gender"),
              Column(
                children: _genders.map((String gender) {
                  return RadioListTile<String>(
                    title: Text(gender),
                    value: gender,
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text("Amenities"),
              Column(
                children: _amenities.map((String amenity) {
                  return CheckboxListTile(
                    title: Text(amenity),
                    value: _selectedAmenities[amenity],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedAmenities[amenity] = value!;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text("Select Location"),
              DropdownButtonFormField<String>(
                value: _selectedLocationId,
                items: _pitchList.map((pitch) {
                  return DropdownMenuItem<String>(
                    value: pitch["id"],
                    child: Text(pitch["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLocationId = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Location'),
              ),

              const SizedBox(height: 16),
              ElevatedButton(onPressed: _addGame, child: const Text('Add Game')),
            ],
          ),
        ),
      ),
    );
  }
}
