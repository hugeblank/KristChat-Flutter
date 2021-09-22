import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Map<int, Transaction> transactions = {};
String root = "krist.ceriat.net";

class Transaction {
  int id;
  String to;
  String from;
  int amount;
  String time;
  String channel;
  Map<String, String> metadata;
  bool epoch;

  Transaction(var info) {
      this.id = info['id'];
      transactions[id] = this;
      this.to = info['to'];
      this.from = info['from'];
      this.amount = info['value'];
      this.channel = info['sent_name'] == null ? null : (info['sent_name'].toString() + ".kst");
      this.metadata = deserializePost(info['metadata']);
      this.epoch = this.id == 1919486; // Any messages before this one will not be rendered

      // Time string logic
      // Uniquely cursed
      DateTime posted = DateTime.parse(info['time']).toLocal();
      if (posted.difference(DateTime.now()).inDays == 0) {
        this.time = "Today at ";
      } else if (posted.difference(DateTime.now()).inDays == 1) {
        this.time = "Yesterday at ";
      } else {
        this.time = posted.month.toString() + "/" + posted.day.toString() + "/" + posted.year.toString() + " ";
      }
      String hour;
      bool pm = (posted.hour/12) > 1;
      if (posted.hour % 12 == 0) {
        hour = "12";
      } else {
        hour = (posted.hour%12).toString();
      }
      this.time += hour + ":" + (posted.minute < 10 ? "0" : "") + posted.minute.toString();
      if (pm) {
        this.time += " PM";
      } else {
        this.time += " AM";
      }
  }

  bool isPost() {
    return this.metadata != null && this.metadata['type'] == 'post';
  }
  
  int getRef() {
    return isPost() && this.metadata['ref'] == null ? null : int.parse(this.metadata['ref']);
  }

}

class Address {
  String address;
  String pkey;
  int balance;

  Address (String address, String pkey) {
    this.address = address;
    this.pkey = pkey;
  }

  Future<void> authenticate() async {
    try {
      // Await the http get response, then decode the json-formatted response.
      var response = await http.post(Uri.https(root, '/login'), body: {
        "privatekey": pkey
      });
      if (response.statusCode == 200) {
        var info = jsonDecode(response.body) as Map<String, dynamic>;
        if (info['ok']) {
          return;
        }
      }
      throw("Cannot authenticate $address");
    } catch (e) {
      throw(e);
    }
  }

  Future<int> getBalance() async {
    if (this.balance != null) {
      return balance;
    }
    try {
      // Await the http get response, then decode the json-formatted response.
      var response = await http.get(Uri.https(root, '/addresses/$address'));
      if (response.statusCode == 200) {
        var info = jsonDecode(response.body) as Map<String, dynamic>;
        if (info['ok']) {
          var addr = info['address'];
          this.balance = addr['balance'];
          return addr['balance'];
        }
      }
      throw("Cannot get balance from address $address");
    } catch (e) {
      try {
        await authenticate();
        return await getBalance();
      } catch (e2) {
        throw(e2);
      }
    }
  }

  void makePost(ScaffoldMessengerState state,  String channel, String text, {int ref, int amount=1}) async {
    try {
      // Await the http get response, then decode the json-formatted response.
      Map<String, String> body = {
        "privatekey": pkey,
        "to": channel,
        "amount": amount.toString(),
        "metadata": serializePost(text, ref)
      };
      var response = await http.post(Uri.https(root, '/transactions'), body: body);
      if (response.statusCode == 200) {
        var info = jsonDecode(response.body) as Map<String, dynamic>;
        if (info['ok']) {
          if (balance != null) {
            balance--;
          }
          var txn = info['transaction'];
          state.showSnackBar(SnackBar(
              content: Text("Sent post! id: " + txn['id'].toString())
          ));
        }
      }
    } catch (e) {
      print(e.toString());
      state.showSnackBar(SnackBar(
          content: Text("Error Sending Post: " + e.toString())
      ));
    }
  }

  Widget buildTrailingThumb(BuildContext context) {
    return FutureBuilder<int>(
      future: getBalance(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        Widget out;
        if (snapshot.hasData) {
          out = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                address,
                textScaleFactor: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                snapshot.data.toString() + " KST",
                textScaleFactor: 0.75
              )
            ]
          );
        } else if (snapshot.hasError) {
          out = Icon(
            Icons.error_outline,
            color: Colors.red
          );
        } else {
          out = CircularProgressIndicator();
        }
        return Container(
          padding:EdgeInsets.all(8),
          child: Center(
            child: out,
          )
        );
      }
    );
  }

  Widget buildDrawerInfo(BuildContext context, Widget title) {
    return FutureBuilder<int>(
        future: getBalance(),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          Widget out;
          if (snapshot.hasData) {
            out = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  title,
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  Text(
                    address,
                    textScaleFactor: 1.1,
                    style: TextStyle(
                      color: Colors.white
                    ),
                  ),
                  Text(
                      snapshot.data.toString() + " KST",
                      textScaleFactor: 1,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white
                      )
                  )
                ]
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            out = Icon(
                Icons.error_outline,
                color: Colors.red
            );
          } else {
            out = CircularProgressIndicator();
          }
          return Container(
              padding:EdgeInsets.all(8),
              child: Center(
                child: out,
              )
          );
        }
    );
  }
}

Future<String> getChannelAddress(String channel) async {
  try {
    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(Uri.https(root, '/names/${channel.replaceAll(".kst", "")}'));
    if (response.statusCode == 200) {
      var info = jsonDecode(response.body) as Map<String, dynamic>;
      if (info['ok']) {
        var name = info['name'];
        return name['owner'];
      }
    }
    throw("Cannot get address from channel $channel");
  } catch (e) {
    throw(e);
  }
}

Future<Transaction> getTransaction(int ref) async {
  if (transactions[ref] != null) {
    return transactions[ref];
  }
  Transaction out;
  var response = await http.get(
      Uri.https(root, "/transactions/$ref"));
  try {
    if (response.statusCode == 200) {
      var info = JsonDecoder().convert(response.body);
      if (info['ok']) {
        out = Transaction(info['transaction']);
      } else {
        throw Exception("krist error: ${info['error']}");
      }
      return out;
    }
    throw Exception("Bad response from server");
  } catch (e) {
    print(e);
  }
  return null;
}

String serializePost(String content, int ref)  {
  String meta = "type=post;content=" + content.replaceAll(";", "&semi");
  if (ref != null) {
    meta += ";ref=" + ref.toString();
  }
  return meta;
}

Map<String, String> deserializePost(String meta) {
  if (meta == null) {return null;}
  Map<String, String> out = {};
  int params = 0;
  List<String> splitmeta = meta.split(";"); // Break up metadata
  for (int i = 0; i < splitmeta.length; i++) {
    if (splitmeta[i].indexOf("type=") == 0) { // Parse type of post
      out["type"] = splitmeta[i].substring(5);
      params++;
    } else if (splitmeta[i].indexOf("content=") == 0) { // Parse content
      out["content"] = splitmeta[i].substring(8);
      params++;
    } else if (splitmeta[i].indexOf("ref=") == 0) { // Parse optional reference
        out["ref"] = splitmeta[i].substring(4);
        try { // Make sure reference can be an int
          int.parse(out["ref"]);
        } catch (e) {
          return null;
        }
    }
  }
  return params > 1 ? out : null;
}

// Algorithms for handling magic address allocation - keeps pressure off server
String hash256(String input) {
  var hash = sha256.convert(utf8.encode(input));
  return hash.toString();
}

String hexToBase36(int input) {
  for (int i= 6; i <= 251; i += 7) {
    if (input <= i) {
      if (i <= 69) {
        return String.fromCharCode((("0").codeUnitAt(0) + (i - 6) / 7).toInt());
      }

      return String.fromCharCode((("a".codeUnitAt(0)) + ((i - 76) / 7)).toInt());
    }
  }

  return "e";
}

String getHashFromKey(String pkey, bool kwallet) {
  return kwallet ? hash256("KRISTWALLET"+pkey)+"-000" : pkey;
}

String getAddressFromKey(String pkey, bool kwallet) {
  pkey = getHashFromKey(pkey, kwallet);

  List<String> chars = ["", "", "", "", "", "", "", "", ""];
  String prefix = "k";
  var hash = hash256(hash256(pkey));

  for (int i = 0; i <= 8; i++) {
    chars[i] = hash.substring(0, 2);
    hash = hash256(hash256(hash));
  }

  for (int i = 0; i <= 8;) {
    int index = int.parse(hash.substring(2 * i, 2 + (2 * i)), radix: 16) % 9;
    if (chars[index].isEmpty) {
      hash = hash256(hash);
    } else {
      prefix += hexToBase36(int.parse(chars[index], radix: 16));
      chars[index] = "";
      i++;
    }
  }
  return prefix;
}