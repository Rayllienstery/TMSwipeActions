//
//  SwipeActionsInteractor.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 03.01.2025.
//

import SwiftUI
import Combine

class SwipeActionsInteractor: ObservableObject {
    @Published var viewModel: SwipeActionsViewModel
    @Published var presenter: SwipeActionsPresenter
    @Published var gestureState: SwipeGestureState

    @Published var viewConfig: SwipeActionsViewConfig

    @Published var offset: CGFloat = 0

    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: SwipeActionsViewModel,
         presenter: SwipeActionsPresenter,
         gestureState: SwipeGestureState,
         viewConfig: SwipeActionsViewConfig) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.gestureState = gestureState
        self.viewConfig = viewConfig

        self.initObservers()
    }

    func dragOnChanged(translation: CGFloat) {
        let dragAmount = translation
        var newValue = dragAmount + gestureState.cachedOffset

        if !presenter.leadingSwipeIsUnlocked, newValue > 0 {
            newValue = 0
        } else if !presenter.trailingSwipeIsUnlocked, newValue < 0 {
            newValue = 0
        }

        self.offset = newValue
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

    func updateOffset(_ newOffset: CGFloat) {
        self.offset = newOffset
    }

    private func initObservers() {
        $offset
            .dropFirst()
            .throttle(for: .seconds(1 / 60), scheduler: DispatchQueue.main, latest: true)
            .sink(receiveValue: { [weak self] newValue in
                guard let self else { return }

                let fullSwipeIsEnabled = switch newValue {
                case let newValue where newValue > 0: viewConfig.leadingFullSwipeIsEnabled
                case let newValue where newValue < 0: viewConfig.trailingFullSwipeIsEnabled
                default: false }

                let swipeDirection = gestureState.swipeDirection
                let contentSize = swipeDirection == .leading ? presenter.leadingViewWidth : presenter.trailingViewWidth
                gestureState.setNewOffset(newValue,
                                          contentSize: contentSize,
                                          safeWidth: presenter.actionWidth,
                                          fullSwipeIsEnabled:  fullSwipeIsEnabled)
                presenter.callVibroIfNeeded(offset: newValue,
                                            swipeDirection: swipeDirection)
            })
            .store(in: &subscriptions)
    }
}
