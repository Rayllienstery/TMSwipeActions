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
                       actionWidth: CGFloat = Config.defaultActionWidth,
                       viewConfig: SwipeActionsViewConfig = .init(),
                       leadingContentIsPresented: Binding<Bool> = .empty,
                       trailingContentIsPresented: Binding<Bool> = .empty ) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: [], trailingActions: actions,
                                           actionWidth: actionWidth, viewConfig: viewConfig,
                                           leadingContentIsPresented: leadingContentIsPresented,
                                           trailingContentIsPresented: trailingContentIsPresented))
    }

    func leadingSwipe(_ actions: [SwipeAction],
                      actionWidth: CGFloat = Config.defaultActionWidth,
                      viewConfig: SwipeActionsViewConfig = .init(),
                      leadingContentIsPresented: Binding<Bool> = .empty,
                      trailingContentIsPresented: Binding<Bool> = .empty ) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: actions, trailingActions: [],
                                           actionWidth: actionWidth, viewConfig: viewConfig,
                                           leadingContentIsPresented: leadingContentIsPresented,
                                           trailingContentIsPresented: trailingContentIsPresented))
    }

    func swipeActions(leadingActions: [SwipeAction],
                      trailingActions: [SwipeAction],
                      actionWidth: CGFloat = Config.defaultActionWidth,
                      viewConfig: SwipeActionsViewConfig = .init(),
                      leadingContentIsPresented: Binding<Bool> = .empty,
                      trailingContentIsPresented: Binding<Bool> = .empty ) -> some View {
        self.modifier(SwipeActionsModifier(leadingActions: leadingActions,
                                           trailingActions: trailingActions,
                                           actionWidth: actionWidth, viewConfig: viewConfig,
                                           leadingContentIsPresented: leadingContentIsPresented,
                                           trailingContentIsPresented: trailingContentIsPresented))
    }
}

public extension Binding where Value == Bool {
    static var empty: Binding<Bool> { .init(get: { false }, set: { _ in }) }
}
