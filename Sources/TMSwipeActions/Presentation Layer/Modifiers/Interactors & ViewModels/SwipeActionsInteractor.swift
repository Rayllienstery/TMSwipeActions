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

    var isLeadingContentVisible: Binding<Bool>
    var isTrailingContentVisible: Binding<Bool>

    private var subscriptions: Set<AnyCancellable> = []

    init(viewModel: SwipeActionsViewModel,
         presenter: SwipeActionsPresenter,
         gestureState: SwipeGestureState,
         viewConfig: SwipeActionsViewConfig,
         isLeadingContentVisible: Binding<Bool>,
         isTrailingContentVisible: Binding<Bool>) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.gestureState = gestureState
        self.viewConfig = viewConfig
        self.isLeadingContentVisible = isLeadingContentVisible
        self.isTrailingContentVisible = isTrailingContentVisible

        self.initObservers()
    }

    func resetOffsetWithAnimation() {
        withAnimation {
            self.isLeadingContentVisible.wrappedValue = false
            self.isTrailingContentVisible.wrappedValue = false
            self.gestureState.offset = 0
            self.gestureState.cachedOffset = 0
            self.presenter.overdragNotified = false
        }
    }

    func updateOffset(_ newOffset: CGFloat) {
        self.offset = newOffset
    }

    func showLeadingContent(flag: Bool) {
        switch flag {
        case true:
            withAnimation {
                self.gestureState.offset = presenter.leadingViewWidth
                self.gestureState.cachedOffset = -presenter.leadingViewWidth
            }
        case false:
            resetOffsetWithAnimation()
        }
    }

    func showTrailingContent(flag: Bool) {
        switch flag {
        case true:
            withAnimation {
                self.gestureState.offset = -presenter.trailingViewWidth
                self.gestureState.cachedOffset = -presenter.trailingViewWidth
            }
        case false:
            resetOffsetWithAnimation()
        }
    }
}

// MARK: - Gesture
extension SwipeActionsInteractor {
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
                withAnimation {
                    self.gestureState.offset = newOffset
                    self.gestureState.cachedOffset = newOffset
                }
//                self.offset = newOffset
//                gestureState.cachedOffset = newOffset
            }
        }
        // Swipe will do nothing and will hide buttons
        else {
            resetOffsetWithAnimation()
        }
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
                let fullSwipeIsEnabled = fullGestureIsEnabled
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

    private var fullGestureIsEnabled: Bool {
        switch gestureState.swipeDirection {
        case .leading: viewConfig.leadingFullSwipeIsEnabled
        case .trailing: viewConfig.trailingFullSwipeIsEnabled }
    }
}
