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

    @Published var ignoreContentChanging: Bool = false

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

    func updateContent(visibility: SwipeContentVisibility) {
        ignoreContentChanging = true
        self.isLeadingContentVisible.wrappedValue = visibility == .leading
        self.isTrailingContentVisible.wrappedValue = visibility == .trailing
        self.presenter.overdragNotified = false
        self.gestureState.overdragged = false
        if visibility != .hidden {
            self.gestureState.swipeDirection = visibility == .leading ? .leading : .trailing
        }
        ignoreContentChanging = false

        let newOffset = switch visibility {
        case .hidden: CGFloat.zero
        case .leading: self.presenter.leadingViewWidth
        case .trailing: -self.presenter.trailingViewWidth
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self else { return }
            withAnimation {
                self.gestureState.offset = newOffset
                self.gestureState.cachedOffset = newOffset
            }
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
                updateContent(visibility: .hidden)
            }
            // Show buttons
            else {
                withAnimation {
                    switch gestureState.swipeDirection {
                    case .leading: updateContent(visibility: .leading)
                    case .trailing: updateContent(visibility: .trailing)
                    }
                }
            }
        }
        // Swipe will do nothing and will hide buttons
        else {
            updateContent(visibility: .hidden)
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
                let swipeDirection = gestureState.swipeDirection
                let contentSize = swipeDirection == .leading ? presenter.leadingViewWidth : presenter.trailingViewWidth
                let fullSwipeIsEnabled = swipeDirection == .leading ? presenter.leadingSwipeIsUnlocked : presenter.trailingSwipeIsUnlocked
                print(swipeDirection, presenter.leadingSwipeIsUnlocked, presenter.trailingSwipeIsUnlocked)

                gestureState.setNewOffset(newValue,
                                          contentSize: contentSize,
                                          safeWidth: presenter.actionWidth,
                                          fullSwipeIsEnabled:  fullGestureIsEnabled)
                presenter.callVibroIfNeeded(offset: newValue,
                                            swipeDirection: swipeDirection,
                                            fullSwipeIsEnabled: fullSwipeIsEnabled)
            })
            .store(in: &subscriptions)
    }

    private var fullGestureIsEnabled: Bool {
        switch gestureState.swipeDirection {
        case .leading: viewConfig.leadingFullSwipeIsEnabled
        case .trailing: viewConfig.trailingFullSwipeIsEnabled }
    }
}

enum SwipeContentVisibility {
    case hidden
    case leading
    case trailing
}
