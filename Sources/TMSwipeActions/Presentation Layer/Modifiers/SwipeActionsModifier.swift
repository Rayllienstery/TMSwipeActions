//
//  SwipeActionsModifier .swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 22.12.2024.
//

import SwiftUI

public extension View {
    func trailingSwipe(_ actions: [SwipeAction], font: Font? = nil) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: [], trailingActions: actions, font: font))
    }

    func leadingSwipe(_ actions: [SwipeAction], font: Font? = nil) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: actions, trailingActions: [], font: font))
    }

    func swipeActions(leadingActions: [SwipeAction],
                      trailingActions: [SwipeAction],
                      font: Font? = nil) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: leadingActions,
                                           trailingActions: trailingActions, font: font))
    }
}
