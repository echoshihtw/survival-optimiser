import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      FlutterMethodChannel(
        name: "runway/icloud_backup",
        binaryMessenger: controller.binaryMessenger
      ).setMethodCallHandler { call, result in
        switch call.method {
        case "documentsPath":
          guard let container = FileManager.default.url(
            forUbiquityContainerIdentifier: nil
          ) else {
            result(nil)
            return
          }
          let documents = container.appendingPathComponent(
            "Documents",
            isDirectory: true
          )
          do {
            try FileManager.default.createDirectory(
              at: documents,
              withIntermediateDirectories: true
            )
            result(documents.path)
          } catch {
            result(FlutterError(
              code: "icloud_directory_error",
              message: error.localizedDescription,
              details: nil
            ))
          }
        case "setMetadata":
          guard
            let args = call.arguments as? [String: Any],
            let metadata = args["metadata"] as? String
          else {
            result(FlutterError(
              code: "invalid_arguments",
              message: "Expected metadata string",
              details: nil
            ))
            return
          }
          let store = NSUbiquitousKeyValueStore.default
          store.set(metadata, forKey: "runway_backup_metadata")
          store.synchronize()
          result(nil)
        case "getMetadata":
          let metadata = NSUbiquitousKeyValueStore.default.string(
            forKey: "runway_backup_metadata"
          )
          result(metadata)
        case "clearMetadata":
          let store = NSUbiquitousKeyValueStore.default
          store.removeObject(forKey: "runway_backup_metadata")
          store.synchronize()
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Blank screen in app switcher — prevents financial data exposure
  override func applicationWillResignActive(_ application: UIApplication) {
    let blurEffect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = window?.bounds ?? .zero
    blurView.tag = 999
    window?.addSubview(blurView)
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    window?.viewWithTag(999)?.removeFromSuperview()
  }
}
