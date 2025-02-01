import Flutter
import UIKit
import GoogleMaps
import dotenv

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    
    let env = DotEnv()
    env.load()
    GMSServices.provideAPIKey(env.get("GOOGLE_MAPS_API_KEY") ?? "")


    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
