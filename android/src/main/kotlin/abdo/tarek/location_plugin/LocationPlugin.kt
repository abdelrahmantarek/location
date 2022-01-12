package abdo.tarek.location_plugin

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import map.app.low_calories_google_map.Helper

/** LocationPlugin */
class LocationPlugin: FlutterPlugin, MethodCallHandler , ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var free_channel : MethodChannel
  lateinit var helper : Helper


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    free_channel = MethodChannel(flutterPluginBinding.binaryMessenger, "location_plugin")
    free_channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(call.method){
      "getLocation" -> helper.getLocation(result)
      "gpsStatusAndroid" -> result.success(helper.gpsIsOk());
      "locationStatusAndroid" -> result.success(helper.locationGranted());
      "requestOpenGpsAndroid" -> helper.requestOpenGps(result);
      "requestLocationPermissionAndroid" -> helper.requestLocationPermission(result);
      else -> {
        result.notImplemented()
      }
    }
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {

    free_channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    helper = Helper(binding.activity,binding)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    TODO("Not yet implemented")
  }

}
