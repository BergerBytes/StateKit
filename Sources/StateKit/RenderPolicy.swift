import Foundation

public enum RenderPolicy {
    case possible
    case notPossible(RenderError)

    public enum RenderError {
        case viewNotReady
        case viewDeallocated
    }

    public var isPossible: Bool {
        switch self {
        case .possible:
            return true
        case .notPossible:
            return false
        }
    }
}
