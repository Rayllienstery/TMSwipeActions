//
//  SwipeActionsModifier.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 22.12.2024.
//

import SwiftUI

public extension View {
    typealias Config = SwipeActionsViewConfig

    func trailingSwipe(_ actions: [SwipeAction],
                       font: Font? = nil,
                       actionWidth: CGFloat = Config.defaultActionWidth) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: [], trailingActions: actions, font: font, actionWidth: actionWidth))
    }

    func leadingSwipe(_ actions: [SwipeAction],
                      font: Font? = nil,
                      actionWidth: CGFloat = Config.defaultActionWidth) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: actions, trailingActions: [], font: font, actionWidth: actionWidth))
    }

    func swipeActions(leadingActions: [SwipeAction],
                      trailingActions: [SwipeAction],
                      font: Font? = nil,
                      actionWidth: CGFloat = Config.defaultActionWidth) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: leadingActions,
                                           trailingActions: trailingActions, font: font, actionWidth: actionWidth))
    }
}
