package com.example.contactapp

import android.Manifest
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "direct.call.channel"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "makeDirectCall") {
                val phoneNumber = call.argument<String>("phoneNumber")
                if (phoneNumber != null) {
                    makeDirectCall(phoneNumber, result)
                } else {
                    result.error("INVALID_NUMBER", "Phone number is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun makeDirectCall(phoneNumber: String, result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_CALL)
        intent.data = Uri.parse("tel:$phoneNumber")

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {
            startActivity(intent)
            result.success(true)
        } else {
            // Ask for permission if not granted
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.CALL_PHONE), 1)
            result.error("NO_PERMISSION", "CALL_PHONE permission not granted", null)
        }
    }
}
