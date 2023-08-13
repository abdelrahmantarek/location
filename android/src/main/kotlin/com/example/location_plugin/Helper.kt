package com.example.location_plugin

import android.Manifest
import android.app.Activity
import android.content.ContentValues.TAG
import android.content.Context
import android.content.Intent
import android.content.IntentSender.SendIntentException
import android.content.pm.PackageManager
import android.location.LocationManager
import android.util.Log
import android.widget.Toast
import androidx.core.app.ActivityCompat
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.common.api.ResolvableApiException
import com.google.android.gms.location.*
import com.google.android.gms.tasks.CancellationTokenSource
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry





class Helper(private var activity: Activity,private var activityBinding: ActivityPluginBinding) : PluginRegistry.RequestPermissionsResultListener,PluginRegistry.ActivityResultListener{





    private var fusedLocationClient: FusedLocationProviderClient = LocationServices.getFusedLocationProviderClient(activity)
    private lateinit var gpsResult: MethodChannel.Result
    private lateinit var locationResult: MethodChannel.Result
    private var getLocationResult: MethodChannel.Result? = null
    private var latitude: Double = 0.0
    private var longitude: Double = 0.0
    private var LOCATION_REQUEST_CODE : Int = 150
    private var GPS_REQUEST_CODE : Int = 160




















    init {
        activityBinding.addRequestPermissionsResultListener(this)
        activityBinding.addActivityResultListener(this)
    }

















    fun getLocation(result: MethodChannel.Result) {
        getLocationResult = result
        fusedLocationClient.lastLocation.addOnSuccessListener { location ->
            // getting the last known or current location
            if(location == null){
                val cancellationTokenSource = CancellationTokenSource()
                fusedLocationClient.getCurrentLocation(LocationRequest.PRIORITY_HIGH_ACCURACY,cancellationTokenSource.token).addOnSuccessListener { locations ->
                    if(locations != null){
                        latitude = locations.latitude
                        longitude = locations.longitude
                        val list: ArrayList<Double> = ArrayList()
                        list.add(latitude)
                        list.add(longitude)
                        cancellationTokenSource.cancel()
                        getLocationResult?.success(list)
                        getLocationResult = null
                    }else{
                        result.success(null)
                        getLocationResult = null
                    }
                }
            }else{
                latitude = location.latitude
                longitude = location.longitude
                val list: ArrayList<Double> = ArrayList()
                list.add(latitude)
                list.add(longitude)
                if(getLocationResult != null){
                    getLocationResult?.success(list)
                    getLocationResult = null
                }
            }
        }
            .addOnFailureListener {
                getLocationResult?.success(null)
                Toast.makeText(activity, "Failed on getting current location", Toast.LENGTH_SHORT).show()
            }
    }


























    fun requestLocationPermission(result: MethodChannel.Result) {
        locationResult = result
        if (locationGranted()) {
            locationResult.success(true)
            return
        }
        ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), LOCATION_REQUEST_CODE)
    }













    fun locationGranted(): Boolean {
        return ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED &&
                ActivityCompat.checkSelfPermission(activity, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
    }


















    fun gpsIsOk(): Boolean {
        return gpsStateNetwork() || gpsStatePROVIDER()
    }




















    private fun gpsStateNetwork(): Boolean {
        val locationManager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
    }












    private fun gpsStatePROVIDER(): Boolean {
        val locationManager = activity.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        return locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)
    }






















    fun requestOpenGps(result: MethodChannel.Result) {
        gpsResult = result
        if (gpsIsOk()) {
            gpsResult.success(true);
            return
        }
        val mSettingsClient = LocationServices.getSettingsClient(activity)
        val locationRequest = LocationRequest.create()
        locationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
        locationRequest.interval = (10 * 1000).toLong()
        locationRequest.fastestInterval = (2 * 1000).toLong()
        val builder = LocationSettingsRequest.Builder().addLocationRequest(locationRequest)
        val mLocationSettingsRequest = builder.build()
        builder.setAlwaysShow(true) //this is the key ingredient
        mSettingsClient.checkLocationSettings(mLocationSettingsRequest)
            .addOnSuccessListener(
                activity
            ) {}
            .addOnFailureListener(
                activity
            ) { e ->
                val statusCode = (e as ApiException).statusCode
                when (statusCode) {
                    LocationSettingsStatusCodes.RESOLUTION_REQUIRED -> try {
                        // Show the dialog by calling startResolutionForResult(), and check the
                        // result in onActivityResult().
                        val rae = e as ResolvableApiException
                        rae.startResolutionForResult(activity, GPS_REQUEST_CODE)
                    } catch (sie: SendIntentException) {
                        Log.i(TAG, "PendingIntent unable to execute request.")
                    }
                    LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE -> {
                        val errorMessage = "Location settings are inadequate, and cannot be " +
                                "fixed here. Fix in Settings."
                        Log.e(TAG, errorMessage)
                        Toast.makeText(activity, errorMessage, Toast.LENGTH_LONG).show()
                    }
                }
            }
    }


    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray): Boolean {
        when (requestCode) {
            LOCATION_REQUEST_CODE -> {
                locationResult.success(locationGranted())
            }
        }
        return true
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            GPS_REQUEST_CODE -> {
                gpsResult.success(gpsIsOk());
            }
        }
        return true
    }

}
