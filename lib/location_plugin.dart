
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_plugin/Locaiton.dart';
import 'package:location_plugin/ui/PopAskopenGpsIos.dart';

class LocationPlugin {
  static const MethodChannel _freeChannel = MethodChannel('location_plugin');


  static Future<Location?> getLocation(BuildContext? context)async{

    if(Platform.isAndroid){

      bool? location = await locationStatusAndroid;
      if(location! == false){
        bool data = await _freeChannel.invokeMethod('requestLocationPermissionAndroid');
        if(data == false){
          return null;
        }
      }


      bool? gps = await gpsStatusAndroid;
      if(gps! == false){
        bool data = await _freeChannel.invokeMethod('requestOpenGpsAndroid');
        if(data == false){
          return null;
        }
      }

    }


    if(Platform.isIOS){



      bool? gps = await gpsStatusIos;
      print("gps status =========  " + gps.toString());

      if(gps! == false){
        bool? result = await showDialog<bool>(context: context!,barrierDismissible: false, builder: (context){
          return PopAskOpenGpsIos(
            onGoSettings: ()async{
              bool data = await _freeChannel.invokeMethod('requestOpenGpsIos');
              // print("gps Request status =========  " + data.toString());
              Navigator.pop(context,data);
            },
            onCancel: (){
              Navigator.pop(context,false);
            },
          );
        });

        if(result == false){
          return null;
        }
      }



      bool? location = await locationStatusIos;
      print("permission status =========  " + location.toString());
      if(location! == false){
        bool data = await _freeChannel.invokeMethod('requestLocationPermissionIos');
        // print("permission Request result =========  " + data.toString());
        if(data == false){
          return null;
        }
      }



    }

    final dynamic data = await _freeChannel.invokeMethod('getLocation');
    return Location.fromList(data);
  }



  static Future<bool?> get locationStatusAndroid async {
    final bool? version = await _freeChannel.invokeMethod('locationStatusAndroid');
    return version;
  }


  static Future<bool?> get locationStatusIos async {
    final bool? version = await _freeChannel.invokeMethod('locationStatusIos');
    return version;
  }

  static Future<bool?> get gpsStatusAndroid async {
    final bool? version = await _freeChannel.invokeMethod('gpsStatusAndroid');
    return version;
  }


  static Future<bool?> get gpsStatusIos async {
    final bool? version = await _freeChannel.invokeMethod('checkGpsIos');
    return version;
  }


  static double distanceBetween(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    var earthRadius = 6378137.0;
    var dLat = _toRadians(endLatitude - startLatitude);
    var dLon = _toRadians(endLongitude - startLongitude);

    var a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(_toRadians(startLatitude)) *
            cos(_toRadians(endLatitude));
    var c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  static _toRadians(double degree) {
    return degree * pi / 180;
  }

  static nearestCoordinates(Location location,List<Location> list) {
    List<double> filter = [];
    for(Location element in list){
       filter.add(distanceBetween(location.lat!,location.lng!,element.lat!,element.lng!));
    }
    return filter.reduce(min);
  }



  



}
