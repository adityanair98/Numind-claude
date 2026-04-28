import Foundation

// xorshift64 — fast, good statistical properties, deterministic from a given seed.
struct SeededRandomGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        // xorshift64 must not start with zero state
        state = seed == 0 ? 6364136223846793005 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
