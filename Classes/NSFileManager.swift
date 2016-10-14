import Foundation

extension NSFileManager {

    public static var cachesDirectory: NSURL {
        return NSFileManager.getDirectory(.CachesDirectory)
    }

    public static func directoryExistsAtPath(path: String) -> Bool {
        var isDir = ObjCBool(true)
        return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
    }

    public static var documentsDirectory: NSURL {
        return NSFileManager.getDirectory(.DocumentDirectory)
    }
    
    public static var downloadDirectory: NSURL {
        return NSFileManager.getOrCreateSubDirectory(NSFileManager.documentsDirectory, subDirName: "Downloads")!
    }

    public static func fileExistsAtPath(path: String?) -> Bool {
        if let path = path where !path.isEmpty {
            var isDir = ObjCBool(false)
            return NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isDir)
        }
        return false
    }

    public static func getDirectory(directory: NSSearchPathDirectory) -> NSURL {
        return NSFileManager.defaultManager().URLsForDirectory(directory, inDomains: .UserDomainMask)[0]
    }

    public static func getDirectorySize(directory: NSURL, recursive: Bool = false) -> UInt64 {
        var result: UInt64 = 0
        let fileManager = NSFileManager.defaultManager()
        if NSFileManager.directoryExistsAtPath(directory.path ?? "") {
            guard let contents = try? fileManager.contentsOfDirectoryAtURL(directory, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles) else {
                return result
            }

            for content in contents {
                if let path = content.path {
                    if fileExistsAtPath(path) {
                        if let attrs: NSDictionary = try? fileManager.attributesOfItemAtPath(path) {
                            result += attrs.fileSize()
                        }
                    } else if directoryExistsAtPath(path) && recursive {
                        result += getDirectorySize(content, recursive: recursive)
                    }
                }
            }
        }
        return result
    }

    public static func getOrCreateSubDirectory(directoryUrl: NSURL, subDirName: String) -> NSURL? {
        let newDir = directoryUrl.URLByAppendingPathComponent(subDirName)
        guard let path = newDir.path else { return nil }
        guard !NSFileManager.directoryExistsAtPath(path) else { return newDir }
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: false, attributes: nil)
            return newDir
        } catch {
            return nil
        }
    }

    public static var libraryDirectory: NSURL {
        return NSFileManager.getDirectory(.LibraryDirectory)
    }
    
    public static func removeFile(filePath: String?) {
        if filePath != nil {
            if fileExistsAtPath(filePath!) {
                let _ = try? NSFileManager.defaultManager().removeItemAtURL(NSURL(string: filePath!)!)
            }
        }
    }
    
    public static func removeFile(dir: NSSearchPathDirectory, fileName: String) {
        let path = NSFileManager.getDirectory(dir).URLByAppendingPathComponent(fileName)
        try! NSFileManager.defaultManager().removeItemAtURL(NSURL(string: "file://\(path)")!)
    }

    public static var temporaryDirectory: NSURL {
        return NSURL(fileURLWithPath: NSTemporaryDirectory())
    }
}
