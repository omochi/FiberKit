public protocol OptionalProtocol {
    associatedtype Wrapped
    
    func asOptional() -> Optional<Wrapped>
}

extension Optional: OptionalProtocol {
    public func asOptional() -> Optional<Wrapped> { self }
}
