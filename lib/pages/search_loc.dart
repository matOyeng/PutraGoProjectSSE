import 'package:flutter/material.dart';
import 'navigation_screen.dart';

class SearchLoc extends StatefulWidget {
  @override
  State<SearchLoc> createState() => _SearchLocState();
}

class _SearchLocState extends State<SearchLoc> {
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PutraGo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            'Enter your location', // one text
            style: TextStyle(fontSize: 40),
          ),
          SizedBox(
            height: 30,
          ),

          // two textfields
          TextField(
            controller: latController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'latitude',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          TextField(
            controller: lngController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'longitute',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () { // one button
                 Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NavigationScreen(
                          double.parse(latController.text),
                          double.parse(lngController.text))));
                },
                child: Text('Get Directions')),
          ),
        ]),
      ),
    );
  }
}
