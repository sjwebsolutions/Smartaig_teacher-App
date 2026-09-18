import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Setup Method Channel safely
    let screenshotChannel = FlutterMethodChannel(name: "com.smartaig.teachers/screenshot",
                                                binaryMessenger: self.registrar(forPlugin: "ScreenshotPlugin")!.messenger())

    NotificationCenter.default.addObserver(
        forName: UIApplication.userDidTakeScreenshotNotification,
        object: nil,
        queue: .main) { _ in
            screenshotChannel.invokeMethod("onScreenshotTaken", arguments: nil)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
