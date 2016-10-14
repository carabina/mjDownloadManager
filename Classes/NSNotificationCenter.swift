import UIKit

extension NSNotificationCenter {
    class func addObserver(observer: AnyObject, selector aSelector: Selector, name aName: String) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: aSelector, name: aName, object: nil)
    }

    class func postNotificationName(aName: String, object anObject: AnyObject?) {
        NSNotificationCenter.defaultCenter().postNotificationName(aName, object: anObject)
    }

    class func postNotificationName(aName: String, object anObject: AnyObject?, userInfo aUserInfo: [NSObject : AnyObject]?) {
        NSNotificationCenter.defaultCenter().postNotificationName(aName, object: anObject, userInfo: aUserInfo)
    }

    class func removeObserver(observer: AnyObject) {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }

    class func removeObserver(observer: AnyObject, name aName: String?) {
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: aName, object: nil)
    }
}
