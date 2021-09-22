import 'package:flutter/material.dart';
import 'package:kristchat/api/route.dart';
import 'package:kristchat/api/krist.dart' as krist;
import 'package:kristchat/screens/messages.dart';
import 'package:kristchat/screens/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  RouteHandler.args['prefs'] = await SharedPreferences.getInstance();
  String pkey = RouteHandler.args['prefs'].getString('pkey');
  if (pkey != null) {
    RouteHandler.args['address'] = krist.Address(krist.getAddressFromKey(pkey, true), krist.getHashFromKey(pkey, true));
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KristChat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteHandler.generateRoute,
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  State createState() {
    if (RouteHandler.args['address'] != null) {
      return Messages();
    } else {
      return Welcome();
    }
  }
}
