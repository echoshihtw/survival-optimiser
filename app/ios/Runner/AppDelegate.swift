import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
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
