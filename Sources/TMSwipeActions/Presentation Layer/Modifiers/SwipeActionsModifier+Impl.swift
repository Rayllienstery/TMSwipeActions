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

import SwiftUI

class SwipeActionsViewModel: ObservableObject {
    @Published var trailingActions: [SwipeAction]
    @Published var leadingActions: [SwipeAction]

    @Published var font: Font

    init(trailingActions: [SwipeAction], leadingActions: [SwipeAction], font: Font) {
        self.trailingActions = trailingActions
        self.leadingActions = leadingActions
        self.font = font
    }
}

public struct SwipeActionsModifier: ViewModifier {
    
    // MARK: - Private
    @StateObject private var viewModel: SwipeActionsViewModel
    
//    private let leadingFullSwipeIsEnabled = true
//    private let trailingFullSwipeIsEnabled = false

    @State private var vibrationService: any VibrationServiceProtocol = VibrationService()

    @State private var offset: CGFloat = 0
    @State private var cachedOffset: CGFloat = 0
    @GestureState private var isDragging = false

    let trailingViewWidth: CGFloat
    let leadingViewWidth: CGFloat

    @State private var contentWidth: CGFloat = 0
    @State private var swipeDirection: SwipeEdge = .trailing
    @State private var userNotified = false

    private let actionWidth: CGFloat

    init(leadingActions: [SwipeAction],
         trailingActions: [SwipeAction],
         font: Font?,
         actionWidth: CGFloat? = nil) {
        self._viewModel = StateObject(wrappedValue: .init(trailingActions: trailingActions,
                                                          leadingActions: leadingActions,
                                                          font: font ?? .caption))
        let actionWidth = actionWidth ?? 70
        self.actionWidth = actionWidth

        self.trailingViewWidth = CGFloat(trailingActions.count) * actionWidth
        self.leadingViewWidth = CGFloat(leadingActions.count) * actionWidth
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                contentWidth = proxy.size.width
                            }
                    }
                }
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .updating($isDragging) { value, state, _ in
                            state = true
                        }
                        .onChanged { value in
                            let dragAmount = value.translation.width
                            offset = dragAmount + cachedOffset
                            swipeDirection = offset >= 0 ? .leading : .trailing
                            if (-offset > trailingViewWidth + actionWidth), !userNotified {
                                userNotified = true
                                vibrationService.vibrate()
                            } else if !trailingOversized, userNotified {
                                userNotified = false
                            }
                        }
                        .onEnded { value in
                            switch swipeDirection {
                            case .trailing:
                                let dragThreshold = actionWidth * CGFloat(viewModel.trailingActions.count) / 2
                                if -offset > dragThreshold {
                                    if -offset > trailingViewWidth + actionWidth {
                                        viewModel.trailingActions.first?.action()
                                        resetOffsetWithAnimation()
                                    } else {
                                        withAnimation(.spring) {
                                            offset = -actionWidth * CGFloat(viewModel.trailingActions.count)
                                        }
                                    }
                                } else {
                                    resetOffsetWithAnimation()
                                }
                                cachedOffset = offset
                            case .leading:
                                let dragThreshold = actionWidth * CGFloat(viewModel.leadingActions.count) / 2
                                if offset > dragThreshold {
                                    if offset > leadingViewWidth + actionWidth {
                                        viewModel.leadingActions.last?.action()
                                        resetOffsetWithAnimation()
                                    } else {
                                        withAnimation(.spring) {
                                            offset = actionWidth * CGFloat(viewModel.trailingActions.count)
                                        }
                                    }
                                } else {
                                    resetOffsetWithAnimation()
                                }
                                cachedOffset = offset
                            }
                        }
                )
//                .background(alignment: .trailing) {
                .background {
                    swipeView
                }
        }
        .clipped()
        .mask { content }
    }

    // MARK: - Private

    @ViewBuilder
    private var swipeView: some View {
        switch swipeDirection {
        case .trailing:
            ActionsView(actions: $viewModel.trailingActions,
                        font: $viewModel.font,
                        offset: $offset,
                        swipeEdge: .trailing,
                        actionWidth: actionWidth) {
                resetOffsetWithAnimation()
            }
        case .leading:
            ActionsView(actions: $viewModel.leadingActions,
                        font: $viewModel.font,
                        offset: $offset,
                        swipeEdge: .leading,
                        actionWidth: actionWidth) {
                resetOffsetWithAnimation()
            }
        }
    }

//    @ViewBuilder
//    private var leadingActionsView: some View {
//        if !leadingActions.isEmpty {
//            HStack(spacing: 0) {
//                ForEach(leadingActions) { action in
//                    let isRightOne = leadingActions[0].id == action.id
//                    Button {
//                        action.action()
//                        withAnimation { resetOffsetWithAnimation() }
//                    } label: {
//                        ZStack {
//                            if let icon = action.icon {
//                                Image(uiImage: icon)
//                                    .renderingMode(.template)
//                            } else if let title = action.title {
//                                Text(title)
//                                    .cornerRadius(10)
//                            } else {
//                                Text("Error")
//                            }
//                        }
//                        .minimumScaleFactor(0.3)
//                        .font(font)
//                        .padding(.horizontal)
//                        .foregroundStyle(.white)
//                        .frame(maxWidth: !isRightOne ? actionWidth : leadingOversized ? leadingHoldWidth : actionWidth)
//                        .frame(maxHeight: .infinity)
//                        .background(action.color)
//                    }
////                    .animation(nil, value: UUID())
//                }
//                Spacer()
//                Rectangle()
//                    .fill(leadingActions.last?.color ?? .clear)
//                    .frame(width: 20)
//            }
//            .frame(alignment: .leading)
//            .background { leadingActions.last?.color ?? .clear }
//        }
//    }

    private var trailingHoldWidth: CGFloat {
        let rightSideActionsWidth = CGFloat(viewModel.trailingActions.count - 1) * actionWidth
        let result = -offset - rightSideActionsWidth
        return result
    }

    private var leadingHoldWidth: CGFloat {
        let leftSideActionsWidth = CGFloat(viewModel.leadingActions.count - 1) * actionWidth
        let result = offset - leftSideActionsWidth
        print("leadingHoldWidth: ", result)
        return result
    }

    private var trailingOversized: Bool {
        return offset <= -trailingViewWidth
    }

    private var leadingOversized: Bool {
        return offset <= leadingViewWidth
    }

    private func resetOffsetWithAnimation() {
        withAnimation(.spring()) {
            offset = 0
            cachedOffset = 0
            userNotified = false
        }
    }
}
