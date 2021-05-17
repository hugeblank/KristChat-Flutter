import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kristchat/api/krist.dart';
import 'package:flutter/cupertino.dart';
import 'package:kristchat/api/message.dart';
import 'package:kristchat/api/route.dart';
import 'package:kristchat/screens/drawer.dart';

class Post extends StatefulWidget {

  Post({Key key}) : super(key: key);

  @override
  PostState createState() => PostState();
}

class PostState extends State<Post> {
  String channel = RouteHandler.channel;
  String title = "New Post";
  Address address = RouteHandler.address;
  String pkey = RouteHandler.pkey;

  PostState();

  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController ctrl = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text(this.title + " to " + channel),
        actions: [
          address.buildTrailingThumb(context)
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ),
      body: Container(
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.topCenter,
        child: FormBuilder(
          key: _formKey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.all(2),
                  alignment: Alignment.bottomCenter,
                    child: FormBuilderTextField(
                    maxLines: null,
                    textAlign: TextAlign.start,
                    autofocus: true,
                    style: ThemeData.light().textTheme.bodyText2,
                    controller: TextEditingController(),
                    focusNode: FocusNode(),
                    maxLength: 255-Message.predictMax(this.channel, null),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(";", replacementString: "&semi")
                    ],
                    validator: (String value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    onChanged: (str) {
                      ctrl.text = str.replaceAll(";", "&semi");
                    },
                    name: 'post',
                  )
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8.0),
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          address.makePost(ScaffoldMessenger.of(context), channel, _formKey.currentState.fields['post'].value);
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text("Post")
                  ),
                ),
              ]
            )
          ),
        ),
    );
  }
}