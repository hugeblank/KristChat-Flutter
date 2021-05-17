// Derived from https://github.com/oodavid/flutterby/blob/master/002-infinite-loading-pull-to-refresh/lib/models.dart

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'krist.dart';
import 'message.dart';

int offset = 0;
Future<List<Transaction>> getPosts(String channel) async {
  List<Transaction> out = [];
  String address = await getChannelAddress(channel);
  try {
    var response = await http.get(
        Uri.https(root, "/addresses/$address/transactions", {'offset': offset.toString() }));
    if (response.statusCode == 200) {
      var info = JsonDecoder().convert(response.body);
      if (info['ok']) {
        var txns = info['transactions'];
        for (int i = 0; i < txns.length; i++) {
          if (txns[i]['metadata'] != null) {
            Transaction tx = Transaction(txns[i]);
            if(tx.isPost() && tx.channel == channel) out.add(tx);
          }
        }
        offset += 50;
        return out;
      } else {
        throw("Bad response from server: $info");
      }
    } else {
      throw("Bad response from server: ${response.statusCode}");
    }
  } catch (e) {
    print(e);
  }
  return null;
}

class MessagesModel {
  Stream<List<Message>> stream;
  bool hasMore;

  bool _isLoading;
  List<Transaction> _data;
  StreamController<List<Transaction>> _controller;
  String _channel;

  MessagesModel(String channel) {
    _channel = channel;
    _data = [];
    _controller = StreamController<List<Transaction>>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map((List<Transaction> rawdata) {
        return rawdata.map((Transaction info) {
            return Message(info);
        }).toList();
    });
    hasMore = true;
    refresh();
  }

  Future<void> refresh() {
    offset = 0;
    return loadMore(clearCachedData: true);
  }

  Future<void> loadMore({bool clearCachedData = false}) {
    if (clearCachedData) {
      _data = [];
      hasMore = true;
    }
    if (_isLoading || !hasMore) {
      return Future.value();
    }
    _isLoading = true;
    return getPosts(_channel).then((txdata) {
      _isLoading = false;
      _data.addAll(txdata);
      hasMore = true;
      _controller.add(_data);
    });
  }
}