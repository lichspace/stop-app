import Foundation
import Testing
@testable import StopApp

@Suite("Schedule model behavior")
struct ScheduleModelsTests {
    private let now = Date(timeIntervalSince1970: 1_700_000_000)

    @Test func dateUsesSelectedMinuteDuration() {
        let date = ScheduleDateCalculator.date(afterMinutes: 35, now: now)

        #expect(abs(date.timeIntervalSince(now) - 35 * 60) < 0.001)
    }

    @Test func menuUsesRequestedMinuteOptions() {
        let minutes = DurationOption.menuOptions.map(\.minutes)

        #expect(minutes == [5, 10, 15, 20, 25, 30, 40, 50, 60])
    }

    @Test func readableDurationConvertsMinutesToHoursAndMinutes() {
        #expect(DurationTextFormatter.readable(minutes: 25) == "25分钟")
        #expect(DurationTextFormatter.readable(minutes: 60) == "1小时")
        #expect(DurationTextFormatter.readable(minutes: 85) == "1小时25分钟")
        #expect(DurationTextFormatter.readable(minutes: 150) == "2小时30分钟")
    }

    @Test func closingApplicationsRequiresATarget() {
        let plan = SchedulePlan(
            action: .quitApplications,
            targets: [],
            fireDate: now.addingTimeInterval(60)
        )

        #expect(plan.validationMessage(relativeTo: now) == "请至少选择一个要关闭的应用")
    }

    @Test func shutdownDoesNotRequireApplicationTarget() {
        let plan = SchedulePlan(
            action: .shutDown,
            targets: [],
            fireDate: now.addingTimeInterval(60)
        )

        #expect(plan.validationMessage(relativeTo: now) == nil)
    }

    @Test func pastDateIsRejectedBeforeTargetValidation() {
        let plan = SchedulePlan(
            action: .quitApplications,
            targets: [],
            fireDate: now.addingTimeInterval(-1)
        )

        #expect(plan.validationMessage(relativeTo: now) == "执行时间必须晚于当前时间")
    }

    @Test func remainingTimeNeverBecomesNegative() {
        let plan = SchedulePlan(
            action: .shutDown,
            targets: [],
            fireDate: now.addingTimeInterval(-60)
        )

        #expect(plan.remainingTime(relativeTo: now) == 0)
    }
}
