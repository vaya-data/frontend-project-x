import 'package:flutter/material.dart';

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
  // This function is called when a button is pressed.
  void _handleButtonPress(String option) {
    print('Button pressed: $option');
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
              onPressed: () => _handleButtonPress('Gamelist screen'),
              child: Text('Gamelist Screen'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleButtonPress('Gamebuilder screen'),
              child: Text('Gamebuilder Screen'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleButtonPress('Pitch adder screen'),
              child: Text('Pitch adder Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
