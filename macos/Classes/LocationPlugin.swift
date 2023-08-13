import Cocoa
import FlutterMacOS

public class LocationPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "location_plugin", binaryMessenger: registrar.messenger)
    let instance = LocationPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("macOS " + ProcessInfo.processInfo.operatingSystemVersionString)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
