import UIKit
import mjDownloadManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, mjDownloadManagerDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        mjDownloadManager.sharedInstance.delegate = self
        return true
    }

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        mjDownloadManager.sharedInstance.backgroundCompletionHandler = completionHandler
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {

    }

    func onDownloadStarted(item: DownloadItem) {
        NSNotificationCenter.defaultCenter().postNotificationName(mjDownloadManager.NOTIFICATION_DOWNLOAD_START, object: self, userInfo: ["item": item])
    }
    
    func onDownloadComplete(item: DownloadItem) {
        NSNotificationCenter.defaultCenter().postNotificationName(mjDownloadManager.NOTIFICATION_DOWNLOAD_COMPLETE, object: self, userInfo: ["item": item])
    }
    
    func onDownloadError(item: DownloadItem, error: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName(mjDownloadManager.NOTIFICATION_DOWNLOAD_ERROR, object: self, userInfo: ["item": item, "error": error])
    }
    
    func onProgressChanged(item: DownloadItem) {
        NSNotificationCenter.defaultCenter().postNotificationName(mjDownloadManager.NOTIFICATION_DOWNLOAD_PROGRESS, object: self, userInfo: ["item": item])
    }
    
    func onAllDownloadsComplete() {
        NSNotificationCenter.defaultCenter().postNotificationName(mjDownloadManager.NOTIFICATION_DOWNLOAD_COMPLETE_ALL, object: self)
    }
}
