import Foundation
import Alamofire

public protocol mjDownloadManagerDelegate {
    func onDownloadStarted(item: DownloadItem)
    func onDownloadComplete(item: DownloadItem)
    func onDownloadError(item: DownloadItem, error: NSError)
    func onProgressChanged(item: DownloadItem)
    func onAllDownloadsComplete()
}

public class mjDownloadManager {
    public static let NOTIFICATION_DOWNLOAD_COMPLETE = "com.github.blackho1e.mjDownloadManager.complete"
    public static let NOTIFICATION_DOWNLOAD_COMPLETE_ALL = "com.github.blackho1e.mjDownloadManager.complete_all"
    public static let NOTIFICATION_DOWNLOAD_ERROR = "com.github.blackho1e.mjDownloadManager.error"
    public static let NOTIFICATION_DOWNLOAD_PROGRESS = "com.github.blackho1e.mjDownloadManager.progress"
    public static let NOTIFICATION_DOWNLOAD_START = "com.github.blackho1e.mjDownloadManager.start"
    
    public var delegate: mjDownloadManagerDelegate?
    private var currentItem: DownloadItem?
    private var items: [DownloadItem] = []
    
    public static var sharedInstance: mjDownloadManager {
        struct Singleton {
            static let instance = mjDownloadManager()
        }
        return Singleton.instance
    }
    
    public static func defaultConfiguration() -> NSURLSessionConfiguration {
        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundleIdentifier + ".background")
        configuration.allowsCellularAccess = false
        configuration.discretionary = true
        configuration.sessionSendsLaunchEvents = true
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.HTTPMaximumConnectionsPerHost = 3
        return configuration
    }
    
    public lazy var backgroundManager: Alamofire.Manager = {
        return Alamofire.Manager(configuration: mjDownloadManager.defaultConfiguration())
    }()
    
    public var backgroundCompletionHandler: (() -> Void)? {
        get {
            return backgroundManager.backgroundCompletionHandler
        }
        set {
            backgroundManager.backgroundCompletionHandler = newValue
        }
    }
}

extension mjDownloadManager {
    
    
    public func addItem(newItem: DownloadItem) {
        for (_, item) in items.enumerate() {
            if item.fileURL == newItem.fileURL {
                return
            }
        }
        items.append(newItem)
    }
    
    public func start() {
        if self.currentItem != nil {
            return;
        }
        guard let item = self.items.first else {
            self.delegate?.onAllDownloadsComplete()
            return
        }
        download(item)
    }
    
    private func download(downloadItem: DownloadItem) {
        downloadItem.start()
            .progress({ bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
                dispatch_async(dispatch_get_main_queue()) {
                    let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
                    downloadItem.progress = progress
                    if progress == 0 {
                        self.delegate?.onDownloadStarted(downloadItem)
                    } else {
                        self.delegate?.onProgressChanged(downloadItem)
                    }
                }
            })
            .response { (request, response, data, error) -> Void in
                if let error = error {
                    if error.code != NSURLErrorCancelled {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.delegate?.onDownloadError(downloadItem, error: error)
                        }
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.onDownloadComplete(downloadItem)
                    }
                }
                if !self.items.isEmpty {
                    self.items.removeFirst()
                }
                guard let nextItem = self.items.first else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.onAllDownloadsComplete()
                    }
                    return
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    self.download(nextItem)
                }
        }
    }
    
    func start(fileURL: String) {
        for (_, item) in items.enumerate() {
            if item.fileURL == fileURL {
                if item.status == .PAUSED {
                    item.resume()
                } else if item.status == .FAILED {
                    item.start()
                }
            } else {
                item.pause()
            }
        }
    }
    
    public func removeAll() {
        for (_, item) in items.enumerate() {
            item.cancel()
        }
        items.removeAll()
    }
    
    public func cancel(fileURL: String) {
        for (index, item) in items.enumerate() {
            if item.fileURL == fileURL {
                item.cancel()
                items.removeAtIndex(index)
                break
            }
        }
    }
    
    public func resume(fileURL: String) {
        for (_, item) in items.enumerate() {
            if item.fileURL == fileURL {
                item.resume()
                break
            }
        }
    }
    
    public func pause(fileURL: String) {
        for (_, item) in items.enumerate() {
            if item.fileURL == fileURL {
                item.pause()
                break
            }
        }
    }
    
    public func getCount() -> Int {
        return items.count
    }
    
    public func getItem(fileURL: String) -> DownloadItem? {
        for (_, item) in items.enumerate() {
            if item.fileURL == fileURL {
                return item;
            }
        }
        return nil
    }
    
    public func getItems() -> [DownloadItem] {
        return self.items
    }
}

extension DownloadItem {
    func defaultDestination() -> Request.DownloadFileDestination {
        return { temporaryURL, response -> NSURL in
            let donwloadPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0].stringByAppendingString("/Downloads")
            do {
                if !NSFileManager.directoryExistsAtPath(donwloadPath) {
                    try NSFileManager.defaultManager().createDirectoryAtPath(donwloadPath, withIntermediateDirectories: false, attributes: nil)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            let downloadPathUrl = NSURL(fileURLWithPath: donwloadPath).URLByAppendingPathComponent(response.suggestedFilename!)
            self.destinationPath = downloadPathUrl.absoluteString
            print(self.destinationPath)
            return downloadPathUrl
        }
    }
}

extension DownloadItem {
    
    private func start() -> Request {
        self.status = .DOWNLOADING
        mjDownloadManager.sharedInstance.currentItem = self
        mjDownloadManager.sharedInstance.backgroundManager.startRequestsImmediately = true
        if resumeData != nil {
            self.request = mjDownloadManager.sharedInstance.backgroundManager.download(resumeData!, destination: self.defaultDestination())
        } else {
            self.request = mjDownloadManager.sharedInstance.backgroundManager.download(.GET, self.fileURL, destination: self.defaultDestination())
        }
        self.request!.progress.kind = NSProgressThroughputKey
        self.request!.progress(downloadProgress)
        self.request!.response(completionHandler: downloadResponse)
        return self.request!
    }
    
    func cancel() {
        self.status = .PAUSED
        self.request?.cancel()
        NSFileManager.removeFile(self.destinationPath)
    }
    
    func resume() {
        if let resumeData = self.resumeData {
            self.status = .DOWNLOADING
            self.request = mjDownloadManager.sharedInstance.backgroundManager.download(resumeData, destination: self.defaultDestination())
                .progress(downloadProgress)
                .response(completionHandler: downloadResponse)
        }
    }
    
    func pause() {
        self.status = .PAUSED
        self.request?.cancel()
    }
    
    private func downloadProgress(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        dispatch_async(dispatch_get_main_queue()) {
            self.status = .DOWNLOADING
        }
    }
    
    private func downloadResponse(request: NSURLRequest?, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) {
        if let error = error {
            if error.code == NSURLErrorCancelled {
                self.status = .PAUSED
                self.resumeData = data
            } else {
                self.status = .FAILED
            }
            
        } else {
            self.status = .SUCCEEDED
        }
    }
}

public class DownloadItem: NSObject {
    
    public enum Status: Int {
        case READY = 0, DOWNLOADING = 5, PAUSED = 7, FAILED = 9, SUCCEEDED = 8
        public func description() -> String {
            switch self {
            case .READY:
                return "대기중"
            case .DOWNLOADING:
                return "진행중"
            case .PAUSED:
                return "잠시멈춤"
            case .FAILED:
                return "에러"
            case .SUCCEEDED:
                return "성공"
            }
        }
    }
    
    private var request: Alamofire.Request?
    private var resumeData: NSData?
    public var fileName: String = ""
    public var fileURL: String = ""
    public var destinationPath: String = ""
    public var status: Status?
    public var progress: Float = 0
    
    private override init() {
        super.init()
    }
    
    public convenience init(fileName: String, fileURL: String, destinationPath: String) {
        self.init()
        self.fileName = fileName
        self.fileURL = fileURL
        self.destinationPath = destinationPath
    }
}
