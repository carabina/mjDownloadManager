import Foundation
import Alamofire
import SwiftyTimer

public class Downloader: DownloaderProtocol {

    var delegate: DownloaderDelegate?
    var items = Queue<DownloadItem>()

    public class var sharedInstance: Downloader {
        struct Singleton {
            static let instance = Downloader()
        }
        return Singleton.instance
    }

    func start(url: String, directory: NSSearchPathDirectory = .DocumentDirectory) {
        let download = DownloadItem(url: url, directory: directory)
        items.push(download)
        download.start()
    }

    func stop(url: String) {
        for i in 0..<items.count {
            if items[i].url.compare(url) == NSComparisonResult.OrderedSame {
                items[i].cancel()
                break
            }
        }
    }

    func cancel(url: String) {
        for i in 0..<items.count {
            if items[i].url.compare(url) == NSComparisonResult.OrderedSame {
                items[i].cancel()
                items.remove(i)
                break
            }
        }
    }

}

protocol DownloaderProtocol {
    func start(url: String, directory: NSSearchPathDirectory)
    func stop(url: String)
    func cancel(url: String)
}

public protocol DownloaderDelegate {
    func downloadCompleted(item: DownloadItem)
    func downloadError(item: DownloadItem, error: NSError)
    optional func downloadProgress(item: DownloadItem, progress: Float)
}

public enum DownloadStatus: Int {
    case Ready, Downloading, Paused, Failed
    public func description() -> String {
        switch self {
        case .Ready:
            return "대기중"
        case .Downloading:
            return "진행중"
        case .Paused:
            return "잠시멈춤"
        case .Failed:
            return "에러"
        default:
            return "Unknown"
        }
    }
}

public class DownloadItem: DownloadItemProtocol {

    var request: Alamofire.Request?
    var url: String
    var directory: NSSearchPathDirectory
    var progress:((percentage: Float) -> Void)?
    var status: String = DownloadStatus.Ready.description()

    init(url: String, directory: NSSearchPathDirectory) {
        self.url = url
        self.directory = directory
    }

    func start() {
        //NSTimer.every(20.seconds, cancel)
        let destination = Alamofire.Request.suggestedDownloadDestination(directory: directory, domain: .UserDomainMask)
        NetworkManager.sharedInstance.backgroundManager.startRequestsImmediately = true
        request = NetworkManager.sharedInstance.backgroundManager.download(.GET, url, destination: destination)
            .progress({ bytesRead, totalBytesRead, totalBytesExpectedToRead in
                /*
                let percentage: Float = Float(totalBytesRead) / Float(totalBytesExpectedToRead)

                 dispatch_async(dispatch_get_main_queue()) {
                     //
                 }

                dispatch_async(GlobalQueueAsyncDispatcher.PriorityDefault, {
                    NSNotificationCenter.defaultCenter().postNotificationName("DownaloadFileServiceNotification", object: nil, userInfo: [url.lastPathComponent! : NSNumber(float: percentage)])
                })
                 */

            })
            .response { (request, response, data, error) -> Void in
                print(response)

                if let error = error {
                    print("Failed with error: \(error)")
                } else {
                    print("Downloaded file successfully")
                }
        }
    }

    func cancel() {
        request?.cancel()
    }

    func resume() {
        request?.resume()
    }

    func suspend() {
        request?.suspend()
    }

    func progress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64) {

    }
}

protocol DownloadItemProtocol {
    func start()
    func cancel()
    func resume()
    func suspend()
    func progress(bytesRead: Int64, totalBytesRead: Int64, totalBytesExpectedToRead: Int64)
}

public class NetworkManager {

    public class var sharedInstance: NetworkManager {
        struct Singleton {
            static let instance = NetworkManager()
        }
        return Singleton.instance
    }

    class func defaultConfiguration() -> NSURLSessionConfiguration {
        let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier!
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(bundleIdentifier + ".background")
        configuration.sessionSendsLaunchEvents = true
        configuration.discretionary = true
        configuration.timeoutIntervalForRequest = 5 * 60
        configuration.timeoutIntervalForResource = 5 * 60
        configuration.HTTPMaximumConnectionsPerHost = 5
        configuration.HTTPAdditionalHeaders = ["Accept" : "application/json"]
        return configuration
    }

    lazy var backgroundManager: Alamofire.Manager = {
        return Alamofire.Manager(configuration: NetworkManager.defaultConfiguration())
    }()

}

public struct Queue<T> {
    private var items = [T]()
    public var count: Int { return items.count }
    public var isEmpty: Bool { return items.count == 0 }
    public mutating func push(value: T) { items.append(value) }
    public mutating func pop() -> T { return items.removeFirst() }
    public mutating func remove(index: Int) { items.removeAtIndex(index) }
    subscript(index: Int) -> T {
        get {
            return items[index]
        }
        set {
            items.insert(newValue, atIndex: index)
        }
    }
}
