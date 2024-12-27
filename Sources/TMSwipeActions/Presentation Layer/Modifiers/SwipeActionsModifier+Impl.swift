//
//  TrailingActionsModifier.swift
//  TrailingActions
//
//  Created by Kostiantyn Kolosov on 20.12.2024.
//

// TODO: - Do not let drag if actions is empty
// TODO: - Flag that disable overswipe action
// TODO: - Leading Gesture
// TODO: - Leading overswipe

// FIXME: - Animation and appearance for swipe, check how it works for the native swipe

import SwiftUI

public struct SwipeActionsModifier: ViewModifier {
    typealias ViewConfig = SwipeActionsViewConfig
    
    // MARK: - Private
    @StateObject private var viewModel: SwipeActionsViewModel
    @StateObject private var presenter: SwipeActionsPresenter

    // Size
    @State private var contentWidth: CGFloat = 0 // Core view width

    // Swipe Gesture Properties
    @StateObject var gestureState: SwipeGestureState = .init()
    @GestureState private var isDragging = false

    init(leadingActions: [SwipeAction],
         trailingActions: [SwipeAction],
         font: Font?,
         actionWidth: CGFloat = ViewConfig.defaultActionWidth) {
        self._viewModel = StateObject(wrappedValue: .init(trailingActions: trailingActions,
                                                          leadingActions: leadingActions,
                                                          font: font ?? .caption))
        let presenter = SwipeActionsPresenter(actionWidth: actionWidth,
                                              leadingSwipeIsUnlocked: !leadingActions.isEmpty,
                                              trailingSwipeIsUnlocked: !trailingActions.isEmpty,
                                              trailingViewWidth: CGFloat(trailingActions.count) * actionWidth,
                                              leadingViewWidth: CGFloat(leadingActions.count) * actionWidth)
        self._presenter = StateObject(wrappedValue: presenter)
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
                .background { swipeView }
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
                        font: $viewModel.font,
                        offset: $gestureState.offset,
                        overdragged: $gestureState.overdragged,
                        swipeEdge: .trailing,
                        actionWidth: presenter.actionWidth) {
                resetOffsetWithAnimation()
            }
        case .leading:
            ActionsView(actions: $viewModel.leadingActions,
                        font: $viewModel.font,
                        offset: $gestureState.offset,
                        overdragged: $gestureState.overdragged,
                        swipeEdge: .leading,
                        actionWidth: presenter.actionWidth) {
                resetOffsetWithAnimation()
            }
        }
    }

    private var trailingHoldWidth: CGFloat {
        let rightSideActionsWidth = CGFloat(viewModel.trailingActions.count - 1) * presenter.actionWidth
        let result = -gestureState.offset - rightSideActionsWidth
        return result
    }

    private var leadingHoldWidth: CGFloat {
        let leftSideActionsWidth = CGFloat(viewModel.leadingActions.count - 1) * presenter.actionWidth
        let result = gestureState.offset - leftSideActionsWidth
        return result
    }

    private func resetOffsetWithAnimation() {
        withAnimation(.spring()) {
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

        gestureState.setNewOffset(newValue)
        presenter.callVibroIfNeeded(offset: newValue,
                                    swipeDirection: gestureState.swipeDirection)
    }

    func dragEnded() {
        switch gestureState.swipeDirection {
        case .trailing:
            let dragThreshold = presenter.actionWidth * CGFloat(viewModel.trailingActions.count) / 2
            if -gestureState.offset > dragThreshold {
                if -gestureState.offset > presenter.trailingViewWidth + presenter.actionWidth {
                    viewModel.trailingActions.first?.action()
                    resetOffsetWithAnimation()
                } else {
                    withAnimation(.spring) {
                        gestureState.offset = -presenter.actionWidth * CGFloat(viewModel.trailingActions.count)
                    }
                }
            } else {
                resetOffsetWithAnimation()
            }
            gestureState.cachedOffset = gestureState.offset
        case .leading:
            let dragThreshold = presenter.actionWidth * CGFloat(viewModel.leadingActions.count) / 2
            if gestureState.offset > dragThreshold {
                if gestureState.offset > presenter.leadingViewWidth + presenter.actionWidth {
                    viewModel.leadingActions.last?.action()
                    resetOffsetWithAnimation()
                } else {
                    withAnimation(.spring) {
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

//    private let leadingFullSwipeIsEnabled = true
//    private let trailingFullSwipeIsEnabled = false
