//
//  SwipeActionsInteractor.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 03.01.2025.
//

import SwiftUI

class SwipeActionsInteractor: ObservableObject {
    @Published var viewModel: SwipeActionsViewModel
    @Published var presenter: SwipeActionsPresenter
    @Published var gestureState: SwipeGestureState

    @Published var viewConfig: SwipeActionsViewConfig

    init(viewModel: SwipeActionsViewModel,
         presenter: SwipeActionsPresenter,
         gestureState: SwipeGestureState,
         viewConfig: SwipeActionsViewConfig) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.gestureState = gestureState
        self.viewConfig = viewConfig
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

        let fullSwipeIsEnabled = switch newValue {
        case let newValue where newValue > 0: viewConfig.leadingFullSwipeIsEnabled
        case let newValue where newValue < 0: viewConfig.trailingFullSwipeIsEnabled
        default: false
        }

        gestureState.setNewOffset(newValue,
                                  contentSize: contentSize,
                                  safeWidth: presenter.actionWidth,
                                  fullSwipeIsEnabled:  fullSwipeIsEnabled)
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
//                    withAnimation(viewConfig.animation) {
                    gestureState.offset = -presenter.actionWidth * CGFloat(viewModel.trailingActions.count)
//                    }
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
//                    withAnimation(viewConfig.animation) {
                    gestureState.offset = presenter.actionWidth * CGFloat(viewModel.leadingActions.count)
//                    }
                }
            } else {
                resetOffsetWithAnimation()
            }
            gestureState.cachedOffset = gestureState.offset
        }
    }

    func resetOffsetWithAnimation() {
//        withAnimation(viewConfig.animation) {
        gestureState.offset = 0
        gestureState.cachedOffset = 0
            presenter.overdragNotified = false
//        }
    }
}
