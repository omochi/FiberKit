import Dispatch

public enum Fibers {
    internal static var current: Any? {
        DispatchQueue.getSpecific(key: currentKey)
    }
    
    internal static var currentKey = DispatchSpecificKey<Any>()
    
    public static func preconditionOnFiber<T, U>(_ fiber: Fiber<T, U>) {
        guard let current = self.current else {
            preconditionFailure("no fiber")
        }
        
        guard let currentFiber = current as? Fiber<T, U>,
            currentFiber === fiber else
        {
            preconditionFailure("other fiber")
        }
    }
    
    public static func preconditionNotOnFiber<T, U>(_ fiber: Fiber<T, U>) {
        guard let current = self.current else {
            return
        }
        
        guard let currentFiber = current as? Fiber<T, U> else {
            return
        }
        
        precondition(currentFiber !== fiber)
    }
}
