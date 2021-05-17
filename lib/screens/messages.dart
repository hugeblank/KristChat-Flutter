import 'package:flutter/material.dart';
import 'package:kristchat/api/kmodels.dart';
import 'package:kristchat/api/krist.dart';
import 'package:kristchat/api/route.dart';
import 'package:flutter/cupertino.dart';
import 'package:kristchat/screens/drawer.dart';

class Messages extends StatefulWidget {

  Messages({Key key}) : super(key: key);

  @override
  MessagesState createState() => MessagesState();
}

class MessagesState extends State<Messages> {
  String title = "KristChat";
  String channel = RouteHandler.channel;
  Address address = RouteHandler.address;

  MessagesState();

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
          Navigator.of(context).pushNamed('/post')
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
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(
                        child: CircularProgressIndicator()
                      )
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Center(child: Text('nothing more to load!')),
                    );
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