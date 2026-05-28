import Foundation

/// A milestone-style "win" worth surfacing to the user after a session.
/// Queued on `ProgressStore.pendingCelebrations`; UI pops one at a time
/// (sequential sheets when more than one fires at once).
///
/// Pack celebrations are enqueued before world celebrations per the spec —
/// so a lesson that closes both a focus pack and its containing world
/// shows the pack sheet first, then the world sheet on dismiss.
enum Celebration: Identifiable, Equatable {
    case packCompleted(Pack)
    case worldCompleted(Module)

    var id: String {
        switch self {
        case .packCompleted(let p):   return "pack:\(p.id)"
        case .worldCompleted(let m):  return "world:\(m.id)"
        }
    }

    static func == (lhs: Celebration, rhs: Celebration) -> Bool {
        lhs.id == rhs.id
    }
}
