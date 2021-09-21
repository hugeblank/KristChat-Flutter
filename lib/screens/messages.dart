import 'package:flutter/material.dart';
import 'package:kristchat/api/kmodels.dart';
import 'package:kristchat/api/krist.dart';
import 'package:kristchat/api/route.dart';
import 'package:flutter/cupertino.dart';
import 'package:kristchat/main.dart';
import 'package:kristchat/screens/drawer.dart';

class MessagesPage extends HomePage {
  MessagesPage({Key key}) : super(key: key);

  @override
  State createState() {
      return Messages();
  }
}

class Messages extends State<HomePage> {
  String title = "KristChat";
  String channel = RouteHandler.channel;
  Address address = RouteHandler.address;

  Messages();

  MessagesModel msgs;
  ScrollController _sctrl = ScrollController();

  @override
  void initState() {
    msgs = MessagesModel(this.channel);
    _sctrl.addListener(() {
      if (_sctrl.position.maxScrollExtent == _sctrl.offset) {
        msgs.loadMore();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _sctrl.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: Text(this.channel),
        actions: [
          address.buildTrailingThumb(context)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat_outlined),
        onPressed: () => {
          Navigator.of(context).pushReplacementNamed('/post')
        },
      ),
      body: StreamBuilder(
        stream: msgs.stream,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator()
            );
          } else {
            return RefreshIndicator(
              child: ListView.builder(
                controller: _sctrl,
                itemCount: snapshot.data.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < snapshot.data.length) {
                    return snapshot.data[index].build(context);
                  } else if (msgs.hasMore) {
                    return Padding (
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: CircularProgressIndicator()
                      )
                    );
                  } else {
                    return null;
                  }
                }
              ),
              onRefresh: msgs.refresh
            );
          }
        },
      )
    );
  }
}