import SwiftUI

// MARK: - Score Tier

/// Encodes the four Numind score tiers — used by the ring, the detail sheet,
/// and any other surface that wants to label or style a score.
enum ScoreTier: CaseIterable {
    case rookie, analyst, sharp, pro

    // MARK: Initialisation

    init(score: Int) {
        switch score {
        case 0..<40:  self = .rookie
        case 40..<70: self = .analyst
        case 70..<85: self = .sharp
        default:      self = .pro
        }
    }

    // MARK: Display

    var name: String {
        switch self {
        case .rookie:  return "Rookie"
        case .analyst: return "Analyst"
        case .sharp:   return "Sharp"
        case .pro:     return "Numind Pro"
        }
    }

    var icon: String {
        switch self {
        case .rookie:  return "brain"
        case .analyst: return "bolt.fill"
        case .sharp:   return "flame.fill"
        case .pro:     return "crown.fill"
        }
    }

    var color: Color {
        switch self {
        case .rookie:  return Theme.Colors.warmOrange
        case .analyst: return Theme.Colors.primaryBlue
        case .sharp:   return Theme.Colors.mindTeal
        case .pro:     return Theme.Colors.growthGreen
        }
    }

    var gradientColors: [Color] {
        switch self {
        case .rookie:  return [Theme.Colors.warmOrange,  Theme.Colors.insightYellow]
        case .analyst: return [Theme.Colors.primaryBlue, Theme.Colors.mindTeal]
        case .sharp:   return [Theme.Colors.mindTeal,    Theme.Colors.growthGreen]
        case .pro:     return [Theme.Colors.growthGreen, Theme.Colors.mindTeal]
        }
    }

    // MARK: Progression

    /// Minimum score to reach this tier.
    var minScore: Int {
        switch self {
        case .rookie:  return 0
        case .analyst: return 40
        case .sharp:   return 70
        case .pro:     return 85
        }
    }

    /// Points needed to reach the next tier, or nil if already at the top.
    func pointsToNext(from score: Int) -> Int? {
        switch self {
        case .rookie:  return max(0, 40 - score)
        case .analyst: return max(0, 70 - score)
        case .sharp:   return max(0, 85 - score)
        case .pro:     return nil
        }
    }

    /// The tier that follows this one, or nil if already at the top.
    var next: ScoreTier? {
        switch self {
        case .rookie:  return .analyst
        case .analyst: return .sharp
        case .sharp:   return .pro
        case .pro:     return nil
        }
    }
}

// MARK: - Score Ring

/// A circular donut ring displaying a 0–100 Numind Score.
///
/// The arc colour and center label update automatically based on the score tier.
/// An optional delta badge floats below the ring.
///
/// Usage:
/// ```swift
/// NumindScoreRing(score: 72, delta: +8, size: 120)
/// NumindScoreRing(score: 45)          // compact, no delta
/// ```
struct NumindScoreRing: View {
    let score: Int
    /// Change vs. 7 days ago. Nil hides the badge; 0 shows a neutral badge.
    var delta: Int? = nil
    /// Overall diameter of the ring.
    var size: CGFloat = 88

    private var tier: ScoreTier { ScoreTier(score: score) }
    private var progress: Double { Double(max(0, min(100, score))) / 100 }
    private var ringWidth: CGFloat { max(6, size * 0.13) }

    private var arcGradient: LinearGradient {
        LinearGradient(colors: tier.gradientColors,
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        ZStack {
            // Track ring
            Circle()
                .stroke(Theme.Colors.mutedTint, lineWidth: ringWidth)

            // Filled arc — score-tiered gradient
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    arcGradient,
                    style: StrokeStyle(lineWidth: ringWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: score)

            // Center: tier icon (large rings only) + number + tier name
            VStack(spacing: 1) {
                if size >= 80 {
                    Image(systemName: tier.icon)
                        .font(.system(size: size * 0.13, weight: .semibold))
                        .foregroundStyle(tier.color)
                }
                Text("\(score)")
                    .font(.system(size: size * 0.26, weight: .bold, design: .rounded))
                    .foregroundStyle(tier.color)
                    .contentTransition(.numericText())
                Text(tier.name.uppercased())
                    .font(.system(size: max(6, size * 0.085), weight: .bold))
                    .foregroundStyle(tier.color.opacity(0.7))
                    .kerning(0.4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .frame(width: size * 0.62)   // constrain to ring interior

            // Delta badge — positioned just below the ring
            if let delta {
                deltaBadge(delta)
                    .offset(y: size * 0.44)
            }
        }
        .frame(width: size, height: size + (delta != nil ? size * 0.22 : 0))
    }

    @ViewBuilder
    private func deltaBadge(_ delta: Int) -> some View {
        let isPositive = delta > 0
        let isNeutral  = delta == 0
        let label      = isNeutral ? "—" : (isPositive ? "+\(delta)" : "\(delta)")
        let color: Color = isNeutral ? Theme.Colors.mutedText
                         : isPositive ? Theme.Colors.mindTeal
                         : Theme.Colors.errorSoftRed

        Text(label)
            .font(.system(size: max(9, size * 0.13), weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - Previews

#Preview("Score ring — all tiers") {
    VStack(spacing: 24) {
        // One ring per tier
        HStack(spacing: 20) {
            VStack(spacing: 6) {
                NumindScoreRing(score: 25,  delta: nil, size: 80)
                Text("Starter").font(.caption).foregroundStyle(.secondary)
            }
            VStack(spacing: 6) {
                NumindScoreRing(score: 55,  delta: 4,   size: 80)
                Text("Building").font(.caption).foregroundStyle(.secondary)
            }
            VStack(spacing: 6) {
                NumindScoreRing(score: 76,  delta: 8,   size: 80)
                Text("Strong").font(.caption).foregroundStyle(.secondary)
            }
            VStack(spacing: 6) {
                NumindScoreRing(score: 92,  delta: 12,  size: 80)
                Text("Expert").font(.caption).foregroundStyle(.secondary)
            }
        }
        NumindScoreRing(score: 88, delta: 9, size: 140)
    }
    .padding()
    .background(Theme.Colors.softBackground)
}
