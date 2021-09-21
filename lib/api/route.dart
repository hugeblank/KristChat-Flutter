import 'package:flutter/material.dart';
import 'package:kristchat/main.dart';
import 'package:kristchat/screens/messages.dart';
import 'package:kristchat/screens/post.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'krist.dart';

class RouteHandler {
  static String current = '/';
  static String channel = 'allchat.kst';
  static Address address;
  static String pkey;
  static SharedPreferences prefs;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    current = settings.name;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (context) => HomePage());
      case '/messages':
        return MaterialPageRoute(builder: (context) => MessagesPage());
      case '/channels':
        //return MaterialPageRoute(builder: (context) => Channels());
      case '/accounts':
        //return MaterialPageRoute(builder: (context) => Accounts());
      case '/post':
        return MaterialPageRoute(builder: (context) => Post());
      default:
        return MaterialPageRoute(builder: (context) => HomePage());
    }
  }
}