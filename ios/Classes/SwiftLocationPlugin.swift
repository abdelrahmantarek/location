import Flutter
import UIKit

public class SwiftLocationPlugin: NSObject, FlutterPlugin {
    
    let location : Location = Location()
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "location_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftLocationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "getLocation":
        location.getLocation(result)
        break;
      case "locationStatusIos":
        location.getLocationStatusPermission(result)
        break;
      case "requestLocationPermissionIos":
        location.requestLocationPermission(result)
        break;
      case "checkGpsIos":
        location.getLocationStatus(result)
        break;
      case "requestOpenGpsIos":
        location.requestOpenGps(result)
        break;
      case "openSettingsIos":
        location.openSettingsLocationPermissionIos()
        result(true)
        break;
          
        default:
            print("default ")
      }
  }
}
