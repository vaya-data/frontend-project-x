import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
//package helps make http request to fetch game data from an api
import 'dart:convert';
//convert library is used to convert json data recieved from api into dart objects
import 'package:intl/intl.dart';
//The intl package is used for formatting dates and times.




class GameListScreen extends StatefulWidget {
  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  Map<String, List<Map<String, String>>> gamesByDate = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGameData();
  }

  

  // Fetch game data from API
  Future<void> fetchGameData() async {
    final url = Uri.parse(
        'http://10.0.2.2:5001/project-x-384a0/us-central1/api/game/games');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> gameList = json.decode(response.body);
        Map<String, List<Map<String, String>>> tempGamesByDate = {};

        for (var game in gameList) {
          DateTime gameDate =
              DateTime.parse(game['startTime']).toLocal(); // Convert to local time
          String formattedDate = DateFormat('yyyy-MM-dd').format(gameDate); // Format as a string

          String gameName = game['name'];
          String gameTime = DateFormat('hh:mm a').format(gameDate);

          if (!tempGamesByDate.containsKey(formattedDate)) {
            tempGamesByDate[formattedDate] = [];
          }

          tempGamesByDate[formattedDate]!.add({
            "name": gameName,
            "time": gameTime,
          });
        }

        setState(() {
          gamesByDate = tempGamesByDate;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load game data');
      }
    } catch (error) {
      print('Error fetching game data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Get games for the selected date
  List<Map<String, String>> _getGamesForDay(DateTime day) {
    String formattedDay = DateFormat('yyyy-MM-dd').format(day);
    return gamesByDate[formattedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Game List")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar Widget
              TableCalendar(
  focusedDay: _selectedDay,
  firstDay: DateTime(2020, 1, 1), // Allow past selection
  lastDay: DateTime(2040, 12, 31), // Future selection enabled
  calendarFormat: CalendarFormat.week,

  availableCalendarFormats: {
    CalendarFormat.month: 'Month', // Enables month scrolling
    CalendarFormat.week: 'Week',
  },
  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
  onDaySelected: (selectedDay, focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  },
  onPageChanged: (focusedDay) {

    //selected day become the first visible day in the week
    DateTime newStartOfWeek = focusedDay.subtract(Duration(days: focusedDay.weekday - 1));
    setState(() {
      _selectedDay =  newStartOfWeek;// focusedDay; // Maintain selection when scrolling
    });
  },
  headerStyle: HeaderStyle(
    formatButtonVisible: true, // Allow user to toggle formats
    titleCentered: true,
  ),
  calendarStyle: CalendarStyle(
    selectedDecoration: BoxDecoration(
      color: Colors.deepPurple,
      shape: BoxShape.circle,
    ),
    todayDecoration: BoxDecoration(
      color: Colors.purpleAccent,
      shape: BoxShape.circle,
    ),
  ),
  pageAnimationEnabled: true, // Smooth scrolling
),


                SizedBox(height: 10),

                // Game List
                Expanded(
                  child: _getGamesForDay(_selectedDay).isEmpty
                      ? Center(
                          child: Text(
                            "No games available on this date",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _getGamesForDay(_selectedDay).length,
                          itemBuilder: (context, index) {
                            var game = _getGamesForDay(_selectedDay)[index];
                            return Card(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ListTile(
                                leading: Icon(Icons.sports_soccer,
                                    color: Colors.deepPurple),
                                title: Text(
                                  game['name'] ?? 'Unknown Game',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "Time: ${game['time']}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}


