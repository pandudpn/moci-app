import Flutter
import UIKit
import AVFoundation

/// Kanal platform milik Moci: backup, sesi audio, dan TTS perangkat.
class MociChannels: NSObject, FlutterPlugin {
  private static let synthesizer = AVSpeechSynthesizer()

  static func register(with registrar: FlutterPluginRegistrar) {
    registerAudioSession(registrar)
    registerTts(registrar)
    let backup = FlutterMethodChannel(name: "moci/backup", binaryMessenger: registrar.messenger())
    backup.setMethodCallHandler { call, result in
      switch call.method {
      case "exclude":
        guard let args = call.arguments as? [String: Any], let path = args["path"] as? String else {
          result(FlutterError(code: "bad_args", message: "path wajib ada", details: nil))
          return
        }
        var url = URL(fileURLWithPath: path)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        do {
          try url.setResourceValues(values)
          result(nil)
        } catch {
          result(FlutterError(code: "exclude_failed", message: error.localizedDescription, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// Kategori playback: suara tetap terdengar saat sakelar senyap menyala.
  private static func registerAudioSession(_ registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "moci/audio_session", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "playback":
        do {
          let session = AVAudioSession.sharedInstance()
          try session.setCategory(.playback, mode: .default)
          try session.setActive(true)
          result(nil)
        } catch {
          result(FlutterError(code: "session_failed", message: error.localizedDescription, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  /// TTS perangkat untuk narasi. Ucapan diantrekan; `stop` memotong antrean.
  private static func registerTts(_ registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "moci/tts", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "speak":
        guard let args = call.arguments as? [String: Any],
          let text = args["text"] as? String,
          let lang = args["lang"] as? String
        else {
          result(FlutterError(code: "bad_args", message: "text dan lang wajib ada", details: nil))
          return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: lang == "id" ? "id-ID" : "en-US")
        utterance.rate = 0.45
        synthesizer.speak(utterance)
        result(nil)
      case "stop":
        synthesizer.stopSpeaking(at: .immediate)
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
