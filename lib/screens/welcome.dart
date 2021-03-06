import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kristchat/api/route.dart';
import 'package:kristchat/main.dart';
import 'package:kristchat/api/krist.dart' as krist;

class Welcome extends State<HomePage> {
  String address = "";
  void updateAddress(String addr) {
    setState(() {
      address = addr;
    });
  }

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  SharedPreferences prefs;

  void submit() {
    if (_formKey.currentState.validate()) {
      RouteHandler.args['prefs'].setString('pkey', _formKey.currentState.fields['password'].value);
      RouteHandler.args['address'] = krist.Address(address, krist.getHashFromKey(_formKey.currentState.fields['password'].value, true));
      Navigator.of(context).pushReplacementNamed("/messages");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Log In/Generate Address")
      ),
      body: Center(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Log into KristChat",
                textScaleFactor: 1.5,
              ),
              Text("Your Address:"),
              Text(
                address,
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: FormBuilderTextField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter private key',
                  ),
                  validator: (String value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onChanged: (String value) {
                    updateAddress(krist.getAddressFromKey(value, true));
                  },
                  onSubmitted: (String _) {
                    submit();
                  },
                  name: 'password',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: submit,
                  child: Text("Submit")
                ),
              )
            ],
          )
        )
      )
    );
  }

}
