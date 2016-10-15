import UIKit
import mjDownloadManager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onDownloadFailure), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_FAILURE, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onDownloadFinishAll), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_FINISH_ALL, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onDownloadProgress), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_PROGRESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onDownloadStart), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_START, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.onDownloadSuccess), name: mjDownloadManager.NOTIFICATION_DOWNLOAD_SUCCESS, object: nil)
/*
        let downloadPath = NSFileManager.downloadDirectory.absoluteString
        let fileURL = "https://github.com/Alamofire/Alamofire/archive/4.0.1.zip"
        let fileName = "Alamofire-4.0.1.zip"
        mjDownloadManager.sharedInstance.addItem(fileName, fileURL: fileURL, destinationPath: downloadPath)
*/
        let fileURL2 = "https://github.com/mj-android/mjPermissions/archive/1.0.7.zip"
        let fileName2 = "mjPermissions.zip"
        mjDownloadManager.sharedInstance.addItem(fileName: fileName2, fileURL: fileURL2)
        mjDownloadManager.sharedInstance.addItem(fileName: fileName2, fileURL: fileURL2)
        mjDownloadManager.sharedInstance.start()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(mjDownloadManager.NOTIFICATION_DOWNLOAD_FINISH_ALL)
        NSNotificationCenter.defaultCenter().removeObserver(mjDownloadManager.NOTIFICATION_DOWNLOAD_PROGRESS)
        NSNotificationCenter.defaultCenter().removeObserver(mjDownloadManager.NOTIFICATION_DOWNLOAD_START)
        NSNotificationCenter.defaultCenter().removeObserver(mjDownloadManager.NOTIFICATION_DOWNLOAD_SUCCESS)
    }

    func onDownloadStart(notification: NSNotification) {
        print("onDownloadStart")
    }
    
    func onDownloadProgress(notification: NSNotification) {
        let info = notification.userInfo
        let downloadItem = info?["item"] as! DownloadItem
        print("onDownloadProgress: \(downloadItem.progress)")
        //let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        //self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func onDownloadSuccess(notification: NSNotification) {
        print("onDownloadSuccess")
    }
    
    func onDownloadFailure(notification: NSNotification) {
        print("onDownloadFailure")
    }
    
    func onDownloadFinishAll(notification: NSNotification) {
        print("onDownloadFinish")
    }
}
