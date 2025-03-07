import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/addGame_screen.dart';
import 'package:flutter_application_1/screen/addGamelist_screen.dart';
import 'package:flutter_application_1/screen/addPitch_screen.dart';

void main() {
  runApp(AdminScreen());
}

class AdminScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Screen',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  // This function is called when a button is pressed.
  void _handleButtonPress(BuildContext context, String option) {
    if(option == 'GameBuilder screen'){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddGameScreen()),
      
      );
    }
    else if (option == 'Add Pitch') {
    // Navigate to AddPitchScreen when "Add Pitch" is selected
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  AddPitchScreen()),
    );}
    else if (option == 'Gamelist screen') {
      Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => GameListScreen()),
      );
    }
    else{

      print('Button pressed: $option');
      // You can add navigation for other screens here.

    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Screen'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _handleButtonPress(context,'Gamelist screen'),
              child: Text('Gamelist Screen'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleButtonPress(context,'GameBuilder screen'),
              child: Text('Gamebuilder Screen'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleButtonPress(context, 'Add Pitch'),
              child: Text('Pitch adder Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
