package id.pandudpn.moci

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.speech.tts.TextToSpeech
import android.speech.tts.Voice
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.Locale
import kotlin.math.min
import kotlin.math.sqrt

class MainActivity : FlutterActivity(), EventChannel.StreamHandler {
    private var tts: TextToSpeech? = null
    private var ttsReady = false
    private val pending = mutableListOf<Pair<String, Locale>>()

    private var levelSink: EventChannel.EventSink? = null
    private var recorder: AudioRecord? = null
    private var levelThread: Thread? = null
    private var listening = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        // TTS perangkat untuk narasi di semua mode build; tanpa izin.
        MethodChannel(messenger, "moci/tts")
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
        // Cadangan Ucapkan saat pengenalan luring tidak tersedia: hanya level.
        EventChannel(messenger, "moci/mic_level_events").setStreamHandler(this)
        MethodChannel(messenger, "moci/mic_level")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "available" -> result.success(hasMicPermission())
                    "start" -> {
                        if (!hasMicPermission()) {
                            result.error("no_permission", "izin mikrofon belum ada", null)
                        } else {
                            startLevel()
                            result.success(null)
                        }
                    }
                    "stop" -> {
                        stopLevel()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasMicPermission() =
        checkSelfPermission(Manifest.permission.RECORD_AUDIO) ==
            PackageManager.PERMISSION_GRANTED

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        levelSink = events
    }

    override fun onCancel(arguments: Any?) {
        levelSink = null
    }

    /** AudioRecord 16 kHz mono PCM16 di thread latar; buffer dibuang setelah RMS. */
    private fun startLevel() {
        stopLevel()
        val ukuran = maxOf(
            AudioRecord.getMinBufferSize(
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
            ),
            SAMPLES * 2,
        )
        val baru = try {
            AudioRecord(
                MediaRecorder.AudioSource.MIC,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_IN_MONO,
                AudioFormat.ENCODING_PCM_16BIT,
                ukuran,
            )
        } catch (_: Exception) {
            return
        }
        if (baru.state != AudioRecord.STATE_INITIALIZED) {
            baru.release()
            return
        }
        recorder = baru
        listening = true
        baru.startRecording()
        levelThread = Thread {
            val buffer = ShortArray(SAMPLES)
            while (listening) {
                val n = baru.read(buffer, 0, buffer.size)
                if (n <= 0) continue
                var jumlah = 0.0
                for (i in 0 until n) {
                    val v = buffer[i].toDouble()
                    jumlah += v * v
                }
                val rms = sqrt(jumlah / n) / 32768.0
                val level = min(1.0, rms * 4)
                runOnUiThread { if (listening) levelSink?.success(level) }
            }
        }.also { it.start() }
    }

    private fun stopLevel() {
        listening = false
        levelThread?.let { t ->
            t.join(300)
            if (t.isAlive) t.interrupt()
        }
        levelThread = null
        recorder?.let { r ->
            try {
                r.stop()
            } catch (_: IllegalStateException) {
                // Belum pernah mulai merekam.
            }
            r.release()
        }
        recorder = null
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
            setPitch(PITCH)
            setSpeechRate(SPEECH_RATE)
            bestVoice(locale)?.let { voice = it }
            speak(text, TextToSpeech.QUEUE_ADD, null, null)
        }
    }

    /** Suara luring berderajat tertinggi untuk bahasa itu, kalau ada. */
    private fun bestVoice(locale: Locale): Voice? =
        tts?.voices
            ?.filter { it.locale.language == locale.language && !it.isNetworkConnectionRequired }
            ?.maxByOrNull { it.quality }

    override fun onDestroy() {
        stopLevel()
        tts?.shutdown()
        tts = null
        super.onDestroy()
    }

    private companion object {
        const val SAMPLE_RATE = 16000

        /** 50 ms pada 16 kHz, sama dengan jeda level di Dart. */
        const val SAMPLES = 800

        /** Suara anak: nada naik sedikit, tempo hampir normal. */
        const val PITCH = 1.25f
        const val SPEECH_RATE = 0.95f
    }
}
