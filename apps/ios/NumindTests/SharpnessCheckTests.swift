import XCTest
@testable import Numind

/// Phase 12 — sharpness-check gating + saves prompt + decode-compat.
final class SharpnessCheckTests: XCTestCase {

    private let calendar = Calendar.current

    private func daysAgo(_ n: Int) -> Date {
        calendar.date(byAdding: .day, value: -n, to: Date())!
    }

    // MARK: - Check gate

    func test_checkDue_after28DaysFromAnchor() {
        XCTAssertTrue(SharpnessCheckGate.isCheckDue(lastCheck: nil, anchor: daysAgo(28)))
        XCTAssertFalse(SharpnessCheckGate.isCheckDue(lastCheck: nil, anchor: daysAgo(27)))
        XCTAssertFalse(SharpnessCheckGate.isCheckDue(lastCheck: nil, anchor: nil))
    }

    func test_checkDue_measuresFromLastCheck_notAnchor() {
        // Old anchor but a recent check → not due.
        XCTAssertFalse(SharpnessCheckGate.isCheckDue(lastCheck: daysAgo(5), anchor: daysAgo(90)))
        XCTAssertTrue(SharpnessCheckGate.isCheckDue(lastCheck: daysAgo(30), anchor: daysAgo(90)))
    }

    // MARK: - Saves prompt gate

    func test_savePrompt_weeklyCadenceAndMinimumPractice() {
        XCTAssertFalse(SharpnessCheckGate.isSavePromptDue(lastPrompt: nil, sessionCount: 4))
        XCTAssertTrue(SharpnessCheckGate.isSavePromptDue(lastPrompt: nil, sessionCount: 5))
        XCTAssertFalse(SharpnessCheckGate.isSavePromptDue(lastPrompt: daysAgo(6), sessionCount: 20))
        XCTAssertTrue(SharpnessCheckGate.isSavePromptDue(lastPrompt: daysAgo(7), sessionCount: 20))
    }

    func test_saveChips_deriveFromRecentModules() {
        let recent = SessionRecord(id: UUID(), lessonId: "tip_18_percent",
                                   moduleId: "smart_shopping", date: daysAgo(2),
                                   correctCount: 5, totalCount: 5)
        let old = SessionRecord(id: UUID(), lessonId: "x", moduleId: "investing",
                                date: daysAgo(20), correctCount: 5, totalCount: 5)
        let chips = SharpnessCheckGate.saveChips(sessions: [recent, old])
        XCTAssertEqual(chips.count, 1)
        XCTAssertTrue(chips[0].contains("Tipped"))
    }

    // MARK: - Records stay out of the session log

    @MainActor
    func test_recordSharpnessCheck_neverTouchesSessions() {
        let store = ProgressStore()
        store.reset()
        let before = store.data.sessions.count
        store.recordSharpnessCheck(SharpnessCheckRecord(
            date: Date(), correct: 6, total: 8, medianSeconds: 9
        ))
        XCTAssertEqual(store.data.sessions.count, before)
        XCTAssertEqual(store.sharpnessChecks.count, 1)
        store.reset()
    }

    // MARK: - Decode-compat

    func test_prePhase12Payload_decodesWithNewFieldsNil() throws {
        // Encode a ProgressData, strip the Phase-12 keys, decode again —
        // mirrors a pre-Phase-12 stored payload.
        var data = ProgressData()
        data.bestStreak = 4
        let encoded = try JSONEncoder().encode(data)
        var json = try XCTUnwrap(
            try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
        )
        json.removeValue(forKey: "sharpnessChecks")
        json.removeValue(forKey: "realWorldSaves")
        json.removeValue(forKey: "lastSavePromptDate")
        let stripped = try JSONSerialization.data(withJSONObject: json)

        let decoded = try JSONDecoder().decode(ProgressData.self, from: stripped)
        XCTAssertEqual(decoded.bestStreak, 4)
        XCTAssertNil(decoded.sharpnessChecks)
        XCTAssertNil(decoded.realWorldSaves)
    }
}
