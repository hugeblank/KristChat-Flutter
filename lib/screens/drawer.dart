import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kristchat/api/krist.dart';
import 'package:kristchat/api/route.dart';

import '../main.dart';
import 'messages.dart';
// https://www.youtube.com/watch?v=nyvwx7o277U
class MainDrawer extends StatelessWidget {
  String title = "KristChat";
  Address address = RouteHandler.address;

  MainDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: address.buildDrawerInfo(context, Column(
              children: [
                Text(
                  this.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 32,
                )
              ]
            )),
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Channels'),
            onTap: (){
              Navigator.of(context).popAndPushNamed("/messages");
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text('Profile'),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log out'),
            onTap: (){
              Navigator.of(context).popAndPushNamed("/");
            },
          )
        ],
      ),
    );
  }

}