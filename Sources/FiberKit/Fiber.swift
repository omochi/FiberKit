import Foundation

public final class Fiber<T, U> {
    public typealias Yield = (U) -> T
    public typealias BodyFunc = (@escaping Yield, T) -> U
    private let queue = DispatchQueue(label: "Fiber.queue")
    private let executionQueue = DispatchQueue(label: "Fiber.executionQueue")
    private var paramSemaphore: DispatchSemaphore
    private var resultSemaphore: DispatchSemaphore
    private let body: BodyFunc
    private var isStarted: Bool = false
    private var isExited: Bool = false
    private var isWaiting: Bool = false

    private var param: T?
    private var result: U?
    
    public init(_ body: @escaping BodyFunc) {
        paramSemaphore = DispatchSemaphore(value: 0)
        resultSemaphore = DispatchSemaphore(value: 0)
        self.body = body
    }
    
    public func resume(_ param: T) -> U {
        dispatchPrecondition(condition: .notOnQueue(executionQueue))
        
        do {
            try queue.sync {
                if isExited {
                    throw MessageError("already exited")
                }
                if isWaiting {
                    throw MessageError("already waiting")
                }
                
                isWaiting = true
                result = nil
                
                if !isStarted {
                    isStarted = true
                    executionQueue.async {
                        self.run(param: param)
                    }
                } else {
                    self.param = param
                    paramSemaphore.signal()
                }
            }
            
            resultSemaphore.wait()
            
            return try queue.sync {
                precondition(self.isWaiting)
                
                isWaiting = false
                guard let result = self.result else {
                    throw MessageError("no result")
                }
                self.result = nil
                return result
            }
        } catch {
            fatalError("\(error)")
        }
    }

    private func run(param: T) {
        dispatchPrecondition(condition: .onQueue(executionQueue))
        
        executionQueue.setSpecific(key: Fibers.currentKey, value: self)
        
        let result = body(_yield, param)
        
        executionQueue.setSpecific(key: Fibers.currentKey, value: nil)
        
        queue.sync {
            precondition(isWaiting)
            self.result = result
            isExited = true
            resultSemaphore.signal()
        }
    }
    
    private func _yield(result: U) -> T {
        dispatchPrecondition(condition: .onQueue(executionQueue))
        
        do {
            queue.sync {
                precondition(self.isWaiting)
                self.result = result
                resultSemaphore.signal()
            }
            
            paramSemaphore.wait()
            
            return try queue.sync {
                guard let param = self.param else {
                    throw MessageError("no param")
                }
                self.param = nil
                return param
            }
        } catch {
            fatalError("\(error)")
        }
    }
}

extension Fiber : Sequence where T == Void, U: OptionalProtocol {
    public typealias Element = U.Wrapped
    public typealias Iterator = AnyIterator<Element>
    
    public func makeIterator() -> AnyIterator<Element> {
        return AnyIterator { () -> Element? in
            self.resume(()).asOptional()
        }
    }
}
