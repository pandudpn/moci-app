import Flutter
import UIKit

/// Kanal platform milik Moci. Kanal audio dan TTS ditambahkan di berkas ini oleh task berikutnya.
class MociChannels: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
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
}
