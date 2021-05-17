import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'krist.dart' as krist;
import 'krist.dart';

// Original Lua application had a funky sub-post rainbow, figured I'd the format here too.
List<Color> dcolors = [Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.lightBlue, Colors.purple];

class Message {

  int depth;
  Transaction transaction;

  // Sub-message stuff
  int ref;
  Message subMsg;

  Message(Transaction tx) {
    this.transaction = tx;
    this.depth = 1;
  }

  Message.subMessage(int ref, int depth) {
    this.ref = ref;
    this.depth = depth;
  }

  static int predictMax(String channel, int ref) {
    String meta = channel+";type=post;content=";
    if (ref != null) {
      meta += ";ref=" + ref.toString();
    }
    return meta.length;
  }

  Future<Transaction> getTransaction() async {
    if (this.transaction == null) {
      this.transaction = await krist.getTransaction(this.ref);
    }
    return transaction;
  }

  Future<Widget> getWidget(BuildContext context) async {
    List<Widget> children = [];
    int ref;
    Transaction tx = await this.getTransaction();
    children.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            tx.from,
            style: TextStyle(
              fontWeight: FontWeight.bold
            )
          ),
          Text(tx.time)
        ]
      )
    );
    children.add(Padding(
      padding: EdgeInsets.all(2)
    ));
    children.add(Text(
      tx.metadata["content"],
    ));
    ref = tx.getRef();
    if (ref != null && this.depth <= dcolors.length) {
      subMsg = Message.subMessage(ref, this.depth + 1);
      Transaction stx = await subMsg.getTransaction();
    if (stx.isPost()) {
      children.add(Padding(
          padding: EdgeInsets.all(2)
      ));
      children.add(subMsg.build(context));
    }
  }

    return Container(
      alignment: Alignment.centerLeft,
      color: dcolors[this.depth-1],
      child: Container(
        color: Colors.white,
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children
        )
      )
    );
  }

  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<Widget>(
        future: getWidget(context),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          Widget child;
          if (snapshot.hasData) {
            child = snapshot.data;
          } else if (snapshot.hasError) {
            print(snapshot.error);
            child = Text(snapshot.error.toString());
          } else {
            child = Column(
              children: <Widget>[
                SizedBox(
                  child: CircularProgressIndicator(),
                  width: 20,
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 8, bottom:16),
                  child: Text('Loading Thread...'),
                )
              ],
            );
          }
          return child;
        },
      )
    );
  }

}