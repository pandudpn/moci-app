package id.pandudpn.moci

import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {
    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private val pending = mutableListOf<Pair<String, Locale>>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // TTS perangkat untuk narasi di semua mode build; tanpa izin.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "moci/tts")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "speak" -> {
                        val text = call.argument<String>("text")
                        val lang = call.argument<String>("lang")
                        if (text == null || lang == null) {
                            result.error("bad_args", "text dan lang wajib ada", null)
                        } else {
                            speak(text, if (lang == "id") Locale("id", "ID") else Locale.US)
                            result.success(null)
                        }
                    }
                    "stop" -> {
                        pending.clear()
                        tts?.stop()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun speak(text: String, locale: Locale) {
        val engine = tts
        if (engine == null) {
            pending.add(text to locale)
            tts = TextToSpeech(this) { status ->
                ttsReady = status == TextToSpeech.SUCCESS
                if (ttsReady) pending.forEach { (t, l) -> say(t, l) }
                pending.clear()
            }
        } else if (ttsReady) {
            say(text, locale)
        } else {
            pending.add(text to locale)
        }
    }

    private fun say(text: String, locale: Locale) {
        tts?.apply {
            setLanguage(locale)
            setSpeechRate(0.9f)
            speak(text, TextToSpeech.QUEUE_ADD, null, null)
        }
    }

    override fun onDestroy() {
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }
}
