import 'package:flutter/material.dart';
import 'package:kristchat/main.dart';
import 'package:kristchat/screens/messages.dart';
import 'package:kristchat/screens/post.dart';


class RouteHandler {
  static String current = '/';
  static Map<String, dynamic> args = {
    'channel': 'allchat.kst'
  };

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