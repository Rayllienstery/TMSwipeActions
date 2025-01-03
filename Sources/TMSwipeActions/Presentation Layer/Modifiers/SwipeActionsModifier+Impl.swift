//
//  TrailingActionsModifier.swift
//  TrailingActions
//
//  Created by Kostiantyn Kolosov on 20.12.2024.
//

// TODO: - func showTrailingContent()
// TODO: - Reverse auto action from overdrag
// TODO: - fluid width
// TODO: - Gesture area

// FIXME: - Animation and appearance for swipe, check how it works for the native swipe

import SwiftUI

public struct SwipeActionsModifier: ViewModifier {
    
    // MARK: - Private
    @StateObject private var interactor: SwipeActionsInteractor
    @StateObject private var presenter: SwipeActionsPresenter

    // Size
    @State private var contentWidth: CGFloat = 0 // Core view width
    @StateObject var gestureState: SwipeGestureState

    init(leadingActions: [SwipeAction],
         trailingActions: [SwipeAction],
         actionWidth: CGFloat,
         viewConfig: SwipeActionsViewConfig) {
        let viewModel = SwipeActionsViewModel(trailingActions: trailingActions,
                                              leadingActions: leadingActions)

        let presenter = SwipeActionsPresenter(actionWidth: actionWidth,
                                              leadingSwipeIsUnlocked: !leadingActions.isEmpty,
                                              trailingSwipeIsUnlocked: !trailingActions.isEmpty,
                                              trailingViewWidth: CGFloat(trailingActions.count) * actionWidth,
                                              leadingViewWidth: CGFloat(leadingActions.count) * actionWidth)
        let gestureState = SwipeGestureState()

        self._presenter = StateObject(wrappedValue: presenter)
        self._interactor = StateObject(wrappedValue: .init(viewModel: viewModel,
                                                           presenter: presenter,
                                                           gestureState: gestureState,
                                                           viewConfig: viewConfig))
        self._gestureState = StateObject(wrappedValue: gestureState)
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .background {
                    GeometryReader { proxy in
                        Color.clear.onAppear { contentWidth = proxy.size.width } }
                }
                .offset(x: interactor.gestureState.offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in interactor.dragOnChanged(translation: value.translation.width) }
                        .onEnded { _ in interactor.dragEnded() }
                )
                .background(alignment: interactor.gestureState.swipeDirection.alignment) { swipeView }
        }
        .clipped()
        .mask { content }
    }

    // MARK: - Private
    @ViewBuilder
    private var swipeView: some View {
        switch interactor.gestureState.swipeDirection {
        case .trailing:
            ActionsView(viewConfig: $interactor.viewConfig,
                        actions: $interactor.viewModel.trailingActions,
                        offset: $interactor.gestureState.offset,
                        overdragged: $interactor.gestureState.overdragged,
                        containerWidth: $contentWidth,
                        swipeEdge: .trailing,
                        font: interactor.viewConfig.font,
                        actionWidth: presenter.actionWidth) {
                interactor.resetOffsetWithAnimation()
            }
        case .leading:
            ActionsView(viewConfig: $interactor.viewConfig,
                        actions: $interactor.viewModel.leadingActions,
                        offset: $interactor.gestureState.offset,
                        overdragged: $interactor.gestureState.overdragged,
                        containerWidth: $contentWidth,
                        swipeEdge: .leading,
                        font: interactor.viewConfig.font,
                        actionWidth: presenter.actionWidth) {
                interactor.resetOffsetWithAnimation()
            }
        }
    }
}
