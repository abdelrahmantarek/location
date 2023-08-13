import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:location_plugin/Locaiton.dart';
import 'package:location_plugin/location_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: ()async{
            Location? location = await LocationPlugin.getLocation(context,
                gpsTitle: "gpsTitle",
                gpsSubtitle: "gpsSubtitle",
                cancelText: "cancelText",
                settingsText: "settingsText");
            log(location!.toJson().toString());
          },
        ),
      ),
    );
  }
}