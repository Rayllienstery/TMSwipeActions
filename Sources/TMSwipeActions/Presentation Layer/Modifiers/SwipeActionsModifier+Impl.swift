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
    typealias ViewConfig = SwipeActionsViewConfig
    
    // MARK: - Private
    @StateObject private var viewModel: SwipeActionsViewModel
    @StateObject private var presenter: SwipeActionsPresenter
    private var viewConfig: ViewConfig

    // Size
    @State private var contentWidth: CGFloat = 0 // Core view width

    // Swipe Gesture Properties
    @StateObject var gestureState: SwipeGestureState = .init()
    @GestureState private var isDragging = false

    init(leadingActions: [SwipeAction],
         trailingActions: [SwipeAction],
         actionWidth: CGFloat,
         viewConfig: ViewConfig) {
        self._viewModel = StateObject(wrappedValue: .init(trailingActions: trailingActions,
                                                          leadingActions: leadingActions))
        let presenter = SwipeActionsPresenter(actionWidth: actionWidth,
                                              leadingSwipeIsUnlocked: !leadingActions.isEmpty,
                                              trailingSwipeIsUnlocked: !trailingActions.isEmpty,
                                              trailingViewWidth: CGFloat(trailingActions.count) * actionWidth,
                                              leadingViewWidth: CGFloat(leadingActions.count) * actionWidth)
        self._presenter = StateObject(wrappedValue: presenter)
        self.viewConfig = viewConfig
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .background {
                    GeometryReader { proxy in
                        Color.clear.onAppear { contentWidth = proxy.size.width } }
                }
                .offset(x: gestureState.offset)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { value, state, _ in state = true }
                        .onChanged { value in dragOnChanged(translation: value.translation.width) }
                        .onEnded { _ in dragEnded() }
                )
                .background(alignment: gestureState.swipeDirection.alignment) { swipeView }
        }
        .clipped()
        .mask { content }
    }

    // MARK: - Private
    @ViewBuilder
    private var swipeView: some View {
        switch gestureState.swipeDirection {
        case .trailing:
            ActionsView(actions: $viewModel.trailingActions,
                        offset: $gestureState.offset,
                        overdragged: $gestureState.overdragged,
                        containerWidth: $contentWidth,
                        swipeEdge: .trailing,
                        font: viewConfig.font,
                        actionWidth: presenter.actionWidth) {
                resetOffsetWithAnimation()
            }
        case .leading:
            ActionsView(actions: $viewModel.leadingActions,
                        offset: $gestureState.offset,
                        overdragged: $gestureState.overdragged,
                        containerWidth: $contentWidth,
                        swipeEdge: .leading,
                        font: viewConfig.font,
                        actionWidth: presenter.actionWidth) {
                resetOffsetWithAnimation()
            }
        }
    }

    private func resetOffsetWithAnimation() {
        withAnimation(.spring(duration: 0.3)) {
            gestureState.offset = 0
            gestureState.cachedOffset = 0
            presenter.overdragNotified = false
        }
    }

    func dragOnChanged(translation: CGFloat) {
        let dragAmount = translation
        var newValue = dragAmount + gestureState.cachedOffset

        if !presenter.leadingSwipeIsUnlocked, newValue > 0 {
            newValue = 0
        } else if !presenter.trailingSwipeIsUnlocked, newValue < 0 {
            newValue = 0
        }

        let swipeDirection = gestureState.swipeDirection
        let contentSize = swipeDirection == .leading ? presenter.leadingViewWidth : presenter.trailingViewWidth

        gestureState.setNewOffset(newValue,
                                  contentSize: contentSize,
                                  safeWidth: presenter.actionWidth)
        presenter.callVibroIfNeeded(offset: newValue,
                                    swipeDirection: swipeDirection)
    }

    func dragEnded() {
        switch gestureState.swipeDirection {
        case .trailing:
            let dragThreshold = presenter.actionWidth * CGFloat(viewModel.trailingActions.count) / 2
            if -gestureState.offset > dragThreshold {
                if viewConfig.trailingFullSwipeIsEnabled,
                    -gestureState.offset > presenter.trailingViewWidth + presenter.actionWidth {
                    viewModel.trailingActions.last?.action()
                    resetOffsetWithAnimation()
                } else {
                    withAnimation(.spring(duration: 0.3)) {
                        gestureState.offset = -presenter.actionWidth * CGFloat(viewModel.trailingActions.count)
                    }
                }
            } else {
                resetOffsetWithAnimation()
            }
            gestureState.cachedOffset = gestureState.offset
        case .leading:
            let dragThreshold = presenter.actionWidth * CGFloat(viewModel.leadingActions.count) / 2
            if viewConfig.leadingFullSwipeIsEnabled,
               gestureState.offset > dragThreshold {
                if gestureState.offset > presenter.leadingViewWidth + presenter.actionWidth {
                    viewModel.leadingActions.first?.action()
                    resetOffsetWithAnimation()
                } else {
                    withAnimation(.spring(duration: 0.3)) {
                        gestureState.offset = presenter.actionWidth * CGFloat(viewModel.leadingActions.count)
                    }
                }
            } else {
                resetOffsetWithAnimation()
            }
            gestureState.cachedOffset = gestureState.offset
        }
    }
}
