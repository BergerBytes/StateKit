import Foundation

/// A base type defining an error that is equatable.
public struct EquatableError: Equatable {
    public let error: Error
    
    public init(_ error: Error) {
        self.error = error
    }
    
    public static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        return lhs.error == rhs.error
    }
}

extension Equatable where Self: Error {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs as Error == rhs as Error
    }
}

public func == (lhs: Error, rhs: Error) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
}
