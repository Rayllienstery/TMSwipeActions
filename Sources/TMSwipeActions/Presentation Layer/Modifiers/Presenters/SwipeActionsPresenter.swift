//
//  SwipeActionsPresenter.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 27.12.2024.
//

import SwiftUI

class SwipeActionsPresenter: ObservableObject {
    let actionWidth: CGFloat

    let leadingSwipeIsUnlocked: Bool
    let trailingSwipeIsUnlocked: Bool

    let trailingViewWidth: CGFloat
    let leadingViewWidth: CGFloat

    var overdragNotified = false { didSet { print("overdragNotified: \(overdragNotified) \(Date.now.description)") } }
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

    func callVibro() {
        guard !overdragNotified else { return }
        overdragNotified = true
        vibrationService.vibrate()
    }
}
