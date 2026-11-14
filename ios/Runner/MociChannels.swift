import Flutter
import UIKit
import AVFoundation

/// Kanal platform milik Moci: backup, sesi audio, TTS perangkat, dan level
/// mikrofon untuk cadangan Ucapkan.
class MociChannels: NSObject, FlutterPlugin {
  private static let synthesizer = AVSpeechSynthesizer()
  private static let micLevel = MicLevelHandler()

  static func register(with registrar: FlutterPluginRegistrar) {
    registerAudioSession(registrar)
    registerTts(registrar)
    registerMicLevel(registrar)
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

  /// Level mikrofon lewat tap `AVAudioEngine`; buffer dibuang setelah RMS.
  private static func registerMicLevel(_ registrar: FlutterPluginRegistrar) {
    let events = FlutterEventChannel(
      name: "moci/mic_level_events", binaryMessenger: registrar.messenger())
    events.setStreamHandler(micLevel)
    let channel = FlutterMethodChannel(
      name: "moci/mic_level", binaryMessenger: registrar.messenger())
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "available":
        result(AVAudioSession.sharedInstance().recordPermission == .granted)
      case "start":
        guard AVAudioSession.sharedInstance().recordPermission == .granted else {
          result(FlutterError(code: "no_permission", message: "izin mikrofon belum ada", details: nil))
          return
        }
        do {
          try micLevel.start()
          result(nil)
        } catch {
          result(FlutterError(code: "start_failed", message: error.localizedDescription, details: nil))
        }
      case "stop":
        micLevel.stop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

/// Tap `inputNode` 1024 frame; RMS dinormalkan lalu dikirim di main queue.
final class MicLevelHandler: NSObject, FlutterStreamHandler {
  private let engine = AVAudioEngine()
  private var sink: FlutterEventSink?
  private var running = false

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  func start() throws {
    guard !running else { return }
    let session = AVAudioSession.sharedInstance()
    // Kategori sementara: merekam tanpa memutus musik yang dihentikan layar.
    try session.setCategory(
      .playAndRecord, mode: .default, options: [.defaultToSpeaker, .mixWithOthers])
    try session.setActive(true)
    let input = engine.inputNode
    let format = input.inputFormat(forBus: 0)
    guard format.sampleRate > 0 else {
      throw NSError(
        domain: "moci.mic_level", code: 1,
        userInfo: [NSLocalizedDescriptionKey: "masukan audio tidak tersedia"])
    }
    input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
      guard let self, self.running else { return }
      let level = MicLevelHandler.rms(buffer)
      DispatchQueue.main.async { self.sink?(level) }
    }
    engine.prepare()
    do {
      try engine.start()
    } catch {
      input.removeTap(onBus: 0)
      throw error
    }
    running = true
  }

  func stop() {
    guard running else { return }
    running = false
    engine.inputNode.removeTap(onBus: 0)
    engine.stop()
    // Sesi kembali ke playback untuk narasi dan musik.
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playback, mode: .default)
    try? session.setActive(true)
  }

  private static func rms(_ buffer: AVAudioPCMBuffer) -> Double {
    guard let data = buffer.floatChannelData?[0] else { return 0 }
    let frames = Int(buffer.frameLength)
    guard frames > 0 else { return 0 }
    var jumlah = 0.0
    for i in 0..<frames {
      let v = Double(data[i])
      jumlah += v * v
    }
    return min(1, (jumlah / Double(frames)).squareRoot() * 8)
  }
}
