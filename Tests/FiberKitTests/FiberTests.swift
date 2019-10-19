import XCTest
import FiberKit

final class FiberTests: XCTestCase {
    func test1() {
        let fiber = Fiber<Void, Int?> { (yield, _) in
            yield(0)
            yield(1)
            yield(2)
            return nil
        }
        
        let a = Array(fiber)
        XCTAssertEqual(a, [0, 1, 2])
    }
    
    func test2() {
        let fiber = Fiber<Bool, Int> { (yield, cont) in
            var cont = cont
            var i = 0
            while true {
                guard cont else { return i }
                
                cont = yield(i)
                i += 1
            }
        }
        
        XCTAssertEqual(fiber.resume(true), 0)
        XCTAssertEqual(fiber.resume(true), 1)
        XCTAssertEqual(fiber.resume(false), 2)
    }
}
