import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modernlogintute/pages/search_loc.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 33, 150, 243),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,  
          children:<Widget>[  
            Center(  
              child: Text(
        "LOGGED IN AS: " + user.email!,
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      )
              ), 
              Center(
      child: ElevatedButton(
          child: const Text('Search Location'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchLoc()),
          );
          },
      ),
              ),
          ]
      ),
    );
  }
}
