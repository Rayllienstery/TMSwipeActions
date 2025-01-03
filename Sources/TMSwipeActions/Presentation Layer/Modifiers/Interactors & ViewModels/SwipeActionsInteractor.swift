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
        let actionsCount = CGFloat(actionsCount)
        let actionWidth = presenter.actionWidth
        let dragThreshold = presenter.actionWidth * actionsCount / 2
        let offset = abs(gestureState.offset)
        let fullSwipeWidth = viewWidth + actionWidth

        // Swipe will do something case
        if offset > dragThreshold {
            // Full Swipe Case
            if fullGestureIsEnabled, offset > fullSwipeWidth {
                borderedAction?.action()
                resetOffsetWithAnimation()
            }
            // Show buttons
            else {
                let newOffset = (gestureState.swipeDirection == .leading ? actionWidth : -actionWidth) * actionsCount
                self.offset = newOffset
                gestureState.cachedOffset = newOffset
                print("New Offset: \(newOffset)")
                print(gestureState.cachedOffset)
            }
        }
        // Swipe will do nothing and will hide buttons
        else {
            resetOffsetWithAnimation()
        }
        print("Offset: \(offset)")
    }

    func resetOffsetWithAnimation() {
        withAnimation {
            self.gestureState.offset = 0
            self.gestureState.cachedOffset = 0
            self.presenter.overdragNotified = false
        }
    }

    func updateOffset(_ newOffset: CGFloat) {
        self.offset = newOffset
    }

    // MARK: - Private

    private var fullGestureIsEnabled: Bool {
        switch gestureState.swipeDirection {
        case .leading: viewConfig.leadingFullSwipeIsEnabled
        case .trailing: viewConfig.trailingFullSwipeIsEnabled }
    }

    private var actionsCount: Int {
        switch gestureState.swipeDirection {
        case .trailing: viewModel.trailingActions.count
        case .leading: viewModel.leadingActions.count }
    }

    private var viewWidth: CGFloat {
        switch gestureState.swipeDirection {
        case .trailing: presenter.trailingViewWidth
        case .leading: presenter.leadingViewWidth }
    }

    private var borderedAction: SwipeAction? {
        switch gestureState.swipeDirection {
        case .trailing: viewModel.trailingActions.last
        case .leading: viewModel.trailingActions.first
        }
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
