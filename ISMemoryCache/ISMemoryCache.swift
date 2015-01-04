import UIKit

public enum ISMemoryCacheClearAction {
    case None
    case RemoveUnretainedObjects
    case RemoveAllObjects
}

public class ISMemoryCache: NSObject {
    public var clearActionOnEnteringBackground: ISMemoryCacheClearAction = .RemoveUnretainedObjects
    public var clearActionOnMemoryWarning: ISMemoryCacheClearAction = .RemoveAllObjects
    
    private let semaphore = dispatch_semaphore_create(1)
    private var dictionary = [String: AnyObject]()
    
    override public init() {
        super.init()
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "handleApplicationDidEnterBackgroundNotification:",
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
        
        notificationCenter.addObserver(self,
            selector: "handleApplicationDidReceiveMemoryWarningNotification:",
            name: UIApplicationDidReceiveMemoryWarningNotification,
            object: nil)
    }
    
    deinit {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
    
    public subscript(key: String) -> AnyObject? {
        get {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            let value: AnyObject? = dictionary[key]
            dispatch_semaphore_signal(semaphore)
            return value
        }
        
        set {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
            dictionary[key] = newValue
            dispatch_semaphore_signal(semaphore)
        }
    }
    
    public func performClearAction(action: ISMemoryCacheClearAction) {
        switch (action) {
        case .None:
            break
        
        case .RemoveUnretainedObjects:
            for key in dictionary.keys {
                weak var value: AnyObject? = self[key]
                
                autoreleasepool {
                    self.dictionary[key] = nil
                }
                
                // if value is still non-nil, it is retained by other objects
                if value != nil {
                    dictionary[key] = value
                }
            }
            break
            
        case .RemoveAllObjects:
            for key in dictionary.keys {
                self[key] = nil
            }
            break
        }
    }
    
    func handleApplicationDidEnterBackgroundNotification(notification: NSNotification) {
        performClearAction(clearActionOnEnteringBackground)
    }
    
    func handleApplicationDidReceiveMemoryWarningNotification(notification: NSNotification) {
        performClearAction(clearActionOnMemoryWarning)
    }
}
