import 'dart:convert';

import 'package:bland_tv/bland_video_player.dart';
import 'package:bland_tv/models/channel.dart';
import 'package:bland_tv/utils/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> getLocalChannels() async {
    String content = await rootBundle.loadString(Globals.tvLocal);

    final List parsedJson = json.decode(content.toString());
    final parsed = parsedJson.cast<Map<String, dynamic>>();

    List<Channel> channelList =
        parsed.map<Channel>((json) => Channel.fromJson(json)).toList();
    Globals.channels = channelList;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bland Tv App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: getLocalChannels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error loading assets: ${snapshot.error}'),
              ),
            );
          } else {
            return BlandVideoPlayerApp();
          }
        },
      ),
    );
  }
}
