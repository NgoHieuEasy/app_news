package com.example.read_paper
import android.os.Bundle
import android.view.accessibility.AccessibilityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), AccessibilityManager.AccessibilityStateChangeListener {
    private val CHANNEL = "com.example.read_paper/talkback_channel"
    private var accessibilityManager: AccessibilityManager? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        accessibilityManager = getSystemService(ACCESSIBILITY_SERVICE) as AccessibilityManager
        accessibilityManager?.addAccessibilityStateChangeListener(this)
        // Kiểm tra trạng thái TalkBack khi Activity được tạo
        checkTalkBackStatus()
    }

    override fun onAccessibilityStateChanged(enabled: Boolean) {
        // Gửi thông điệp về trạng thái TalkBack thay đổi đến Flutter
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("onTalkBackStateChanged", enabled)
    }

    private fun checkTalkBackStatus() {
        val isTalkBackEnabled = accessibilityManager?.isEnabled ?: false
        // Gửi kết quả trạng thái TalkBack về Flutter qua MethodChannel
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            .invokeMethod("onTalkBackStateChanged", isTalkBackEnabled)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isTalkBackActive") {
                val isTalkBackEnabled = accessibilityManager?.isEnabled ?: false
                result.success(isTalkBackEnabled)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        accessibilityManager?.removeAccessibilityStateChangeListener(this)
    }
}