
import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location_plugin/Locaiton.dart';
import 'package:location_plugin/ui/PopAskopenGpsIos.dart';

class LocationPlugin {

  static const MethodChannel _freeChannel = MethodChannel('location_plugin');


  static Future<Location?> getLocation(BuildContext? context,{
    required String gpsTitle,
    required String gpsSubtitle,
    required String cancelText,
    required String settingsText,
  })async{

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
            cancelText: cancelText,
            settingsText: settingsText,
            gpsSubtitle: gpsSubtitle,
            gpsTitle: gpsTitle,
            onGoSettings: () async {
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

      IosLocationStatus? locationIos;

      locationIos = await locationStatusIos;

      print(locationIos);

      if(locationIos == IosLocationStatus.notDetermined || locationIos == IosLocationStatus.restricted){

        locationIos = await requestLocationPermissionIos;

      }

      if(locationIos == IosLocationStatus.denied){

        locationIos = await showDialog<IosLocationStatus>(context: context!,barrierDismissible: false, builder: (context){
          return PopAskOpenGpsIos(
            cancelText: cancelText,
            settingsText: settingsText,
            gpsSubtitle: gpsSubtitle,
            gpsTitle: gpsTitle,
            onGoSettings: () async {

              IosLocationStatus settingsResult = await openSettingsIos;
              // print("gps Request status =========  " + data.toString());
              Navigator.pop(context,settingsResult);
            },
            onCancel: (){
              Navigator.pop(context,null);
            },
          );
        });

        print(locationIos);

        if(locationIos == null){
          return null;
        }

        if(locationIos == IosLocationStatus.notDetermined || locationIos == IosLocationStatus.restricted || locationIos == IosLocationStatus.denied){
          return null;
        }

      }

    }

    final dynamic data = await _freeChannel.invokeMethod('getLocation');
    return Location.fromList(data);
  }



static Future<bool?> get allServiceStatus async {
    if(Platform.isAndroid){
      bool? location = await LocationPlugin.locationStatusAndroid;
      bool? gps = await LocationPlugin.gpsStatusAndroid;
      if(!(location ?? false)){
        return false;
      }
      if(!(gps ?? false)){
        return false;
      }
    }
    if(Platform.isIOS){
      IosLocationStatus locationIos = await locationStatusIos;
      bool location = (locationIos == IosLocationStatus.authorizedAlways || locationIos == IosLocationStatus.authorizedWhenInUse);
      bool? gps = await LocationPlugin.gpsStatusIos;
      if(!(location ?? false)){
        return false;
      }
      if(!(gps ?? false)){
        return false;
      }
    }
    return true;
  }



  static Future<bool?> get locationStatusAndroid async {
    final bool? version = await _freeChannel.invokeMethod('locationStatusAndroid');
    return version;
  }

  static Future<IosLocationStatus> get locationStatusIos async {
    final String? state = await _freeChannel.invokeMethod('locationStatusIos');

    switch (state!){
      case "notDetermined":
        return IosLocationStatus.notDetermined;
      case "restricted":
        return IosLocationStatus.restricted;
      case "denied":
        return IosLocationStatus.denied;
      case "authorizedWhenInUse":
        return IosLocationStatus.authorizedWhenInUse;
      case "authorizedAlways":
        return IosLocationStatus.authorizedAlways;
    }
    return IosLocationStatus.denied;
  }

  static Future<IosLocationStatus> get requestLocationPermissionIos async {
    final String? state = await _freeChannel.invokeMethod('requestLocationPermissionIos');
    switch (state!){
      case "notDetermined":
        return IosLocationStatus.notDetermined;
      case "restricted":
        return IosLocationStatus.restricted;
      case "denied":
        return IosLocationStatus.denied;
      case "authorizedWhenInUse":
        return IosLocationStatus.authorizedWhenInUse;
      case "authorizedAlways":
        return IosLocationStatus.authorizedAlways;
    }
    return IosLocationStatus.denied;
  }

  static Future<IosLocationStatus> get openSettingsIos async {
    final String? state = await _freeChannel.invokeMethod('openSettingsIos');
    switch (state!){
      case "notDetermined":
        return IosLocationStatus.notDetermined;
      case "restricted":
        return IosLocationStatus.restricted;
      case "denied":
        return IosLocationStatus.denied;
      case "authorizedWhenInUse":
        return IosLocationStatus.authorizedWhenInUse;
      case "authorizedAlways":
        return IosLocationStatus.authorizedAlways;
    }
    return IosLocationStatus.denied;
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




  Location nearestCoordinates(Location from,List<Location> list) {
    return list.reduce((value, element){
      return LocationPlugin.distanceBetween(from.latitude,from.longitude,value.latitude,value.longitude) < LocationPlugin.distanceBetween(from.latitude,from.longitude,element.latitude,element.longitude) ? value : element;
    });
  }



  Location farthestCoordinates(Location from,List<Location> list) {
    return list.reduce((value, element){
      return LocationPlugin.distanceBetween(from.latitude,from.longitude,value.latitude,value.longitude) > LocationPlugin.distanceBetween(from.latitude,from.longitude,element.latitude,element.longitude) ? value : element;
    });
  }

  static bool isPointInShape(Location point, List<Location> shapePoints) {
    bool isInside = false;
    int j = shapePoints.length - 1;

    for (int i = 0; i < shapePoints.length; i++) {
      Location vertex1 = shapePoints[i];
      Location vertex2 = shapePoints[j];

      if ((vertex1.longitude < point.longitude && vertex2.longitude >= point.longitude) ||
          (vertex2.longitude < point.longitude && vertex1.longitude >= point.longitude)) {
        if (vertex1.latitude + (point.longitude - vertex1.longitude) / (vertex2.longitude - vertex1.longitude) * (vertex2.latitude - vertex1.latitude) < point.latitude) {
          isInside = !isInside;
        }
      }
      j = i;
    }

    return isInside;
  }

}


enum IosLocationStatus{
  notDetermined,
  restricted,
  denied,
  authorizedWhenInUse,
  authorizedAlways,
}

