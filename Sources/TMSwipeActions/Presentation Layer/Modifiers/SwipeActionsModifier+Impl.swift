//
//  TrailingActionsModifier.swift
//  TrailingActions
//
//  Created by Kostiantyn Kolosov on 20.12.2024.
//

// TODO: - Do not let drag if actions is empty
// TODO: - Flag that disable overswipe action
// TODO: - Custon width
// TODO: - Leading Gesture
// TODO: - Leading overswipe

// FIXME: - Animation and appearance for swipe, check how it works for the native swipe
// FIXME: -

import SwiftUI

class SwipeActionsViewConfig {
    // Static
    static let defaultActionWidth: CGFloat = 70
}

class SwipeActionsPresenter: ObservableObject {
    let actionWidth: CGFloat

    init(actionWidth: CGFloat) {
        self.actionWidth = actionWidth
    }
}

public struct SwipeActionsModifier: ViewModifier {
    typealias ViewConfig = SwipeActionsViewConfig
    
    // MARK: - Private
    @StateObject private var viewModel: SwipeActionsViewModel
    @StateObject private var presenter: SwipeActionsPresenter

    @State private var vibrationService: any VibrationServiceProtocol = VibrationService()

    let trailingViewWidth: CGFloat
    let leadingViewWidth: CGFloat

    let leadingSwipeIsUnlocked: Bool
    let trailingSwipeIsUnlocked: Bool

    @State private var userNotified = false

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
        self._presenter = StateObject(wrappedValue: .init(actionWidth: actionWidth))

        self.trailingViewWidth = CGFloat(trailingActions.count) * actionWidth
        self.leadingViewWidth = CGFloat(leadingActions.count) * actionWidth

        self.leadingSwipeIsUnlocked = !leadingActions.isEmpty
        self.trailingSwipeIsUnlocked = !trailingActions.isEmpty
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
        print("leadingHoldWidth: ", result)
        return result
    }

    private var trailingOversized: Bool {
        return gestureState.offset <= -trailingViewWidth
    }

    private var leadingOversized: Bool {
        return gestureState.offset <= leadingViewWidth
    }

    private func resetOffsetWithAnimation() {
        withAnimation(.spring()) {
            gestureState.offset = 0
            gestureState.cachedOffset = 0
            userNotified = false
        }
    }

    func dragOnChanged(translation: CGFloat) {
        let dragAmount = translation
        var newValue = dragAmount + gestureState.cachedOffset

        if !leadingSwipeIsUnlocked, newValue > 0 {
            newValue = 0
        } else if !trailingSwipeIsUnlocked, newValue < 0 {
            newValue = 0
        }

        gestureState.offset = newValue
        gestureState.swipeDirection = gestureState.offset >= 0 ? .leading : .trailing

        if (-gestureState.offset > trailingViewWidth + presenter.actionWidth), !userNotified {
            userNotified = true
            vibrationService.vibrate()
        } else if !trailingOversized, userNotified {
            userNotified = false
        }
    }

    func dragEnded() {
        switch gestureState.swipeDirection {
        case .trailing:
            let dragThreshold = presenter.actionWidth * CGFloat(viewModel.trailingActions.count) / 2
            if -gestureState.offset > dragThreshold {
                if -gestureState.offset > trailingViewWidth + presenter.actionWidth {
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
            // TODO: - Refactor
            let dragThreshold = presenter.actionWidth * CGFloat(viewModel.leadingActions.count) / 2
            if gestureState.offset > dragThreshold {
                if gestureState.offset > leadingViewWidth + presenter.actionWidth {
                    viewModel.leadingActions.last?.action()
                    resetOffsetWithAnimation()
                } else {
                    withAnimation(.spring) {
                        gestureState.offset = presenter.actionWidth * CGFloat(viewModel.trailingActions.count)
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
