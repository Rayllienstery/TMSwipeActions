//
//  SwipeActionsPresenter.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 27.12.2024.
//

import SwiftUI

// TODO: - Vibro is enabled

class SwipeActionsPresenter: ObservableObject {
    let actionWidth: CGFloat

    let leadingSwipeIsUnlocked: Bool
    let trailingSwipeIsUnlocked: Bool

    let trailingViewWidth: CGFloat
    let leadingViewWidth: CGFloat

    var overdragNotified = false
    private var vibrationService: any VibrationServiceProtocol = VibrationService()

    init(actionWidth: CGFloat,
         leadingSwipeIsUnlocked: Bool,
         trailingSwipeIsUnlocked: Bool,
         trailingViewWidth: CGFloat,
         leadingViewWidth: CGFloat) {
        self.actionWidth = actionWidth
        self.leadingSwipeIsUnlocked = leadingSwipeIsUnlocked
        self.trailingSwipeIsUnlocked = trailingSwipeIsUnlocked
        self.trailingViewWidth = trailingViewWidth
        self.leadingViewWidth = leadingViewWidth
    }

    func callVibroIfNeeded(offset: CGFloat, swipeDirection: SwipeEdge, fullSwipeIsEnabled: Bool) {
        guard fullSwipeIsEnabled else { return }

        let trailingOffset = -offset > trailingViewWidth + actionWidth
        let leadingOffset = offset > leadingViewWidth + actionWidth
        let oversizeStatus = swipeDirection == .trailing ? !trailingIsOversized(offset) : !leadingIsOversized(offset)

        if (trailingOffset || leadingOffset), !overdragNotified {
            callVibro()
        } else if oversizeStatus, overdragNotified {
            overdragNotified = false
        }
    }

    private func callVibro() {
        guard !overdragNotified else { return }
        overdragNotified = true
        vibrationService.vibrate()
    }

    func trailingIsOversized(_ offset: CGFloat) -> Bool { offset <= -trailingViewWidth }

    func leadingIsOversized(_ offset: CGFloat) -> Bool { offset >= leadingViewWidth }
}
