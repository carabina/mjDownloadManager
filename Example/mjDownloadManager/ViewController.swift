import UIKit
import mjDownloadManager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onDownloadComplete(_:)), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_COMPLETE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onAllDownloadsComplete(_:)), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_COMPLETE_ALL, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onDownloadProgressChanged(_:)), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_PROGRESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onDownloadStart(_:)), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_START, object: nil)
  
        let downloadPath = NSFileManager.downloadDirectory.absoluteString
        let fileURL = "https://github.com/Alamofire/Alamofire/archive/4.0.1.zip"
        let fileName = NSURL(string: fileURL)?.lastPathComponent
        mjDownloadManager.sharedInstance.addItem(DownloadItem(fileName: fileName!, fileURL: fileURL, destinationPath: downloadPath))
        print(downloadPath)
        print(fileName!)

        let fileURL2 = "https://github.com/mj-android/mjPermissions/archive/1.0.7.zip"
        let fileName2 = NSURL(string: fileURL2)?.lastPathComponent
        mjDownloadManager.sharedInstance.addItem(DownloadItem(fileName: fileName2!, fileURL: fileURL2, destinationPath: downloadPath))
        mjDownloadManager.sharedInstance.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(mjDownloadManager.NOTIFICATION_DOWNLOAD_COMPLETE)
        NSNotificationCenter.defaultCenter().removeObserver(mjDownloadManager.NOTIFICATION_DOWNLOAD_COMPLETE_ALL)
        NSNotificationCenter.defaultCenter().removeObserver(mjDownloadManager.NOTIFICATION_DOWNLOAD_PROGRESS)
        NSNotificationCenter.defaultCenter().removeObserver(mjDownloadManager.NOTIFICATION_DOWNLOAD_START)
    }

    func onDownloadStart(notification: NSNotification) {
        print("onDownloadStart")
    }
    
    func onAllDownloadsComplete(notification: NSNotification) {
        print("onAllDownloadsComplete")
    }
    
    func onDownloadComplete(notification: NSNotification) {
        print("onDownloadComplete")
    }
    
    func onDownloadProgressChanged(notification: NSNotification) {
        let info = notification.userInfo
        let downloadItem = info?["item"] as! DownloadItem
        print("progress: \(downloadItem.progress)")
        //let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }

}
