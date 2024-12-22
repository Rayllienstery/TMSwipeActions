//
//  TrailingActionsModifier.swift
//  TrailingActions
//
//  Created by Kostiantyn Kolosov on 20.12.2024.
//

// TODO: - Vibration on action after overswipe
// TODO: - Do not let drag if actions is empty
// TODO: - Flag that disable overswipe action
// TODO: - Leading Gesture
// TODO: - Custon width

import SwiftUI

public struct SwipeActionsModifier: ViewModifier {
    // MARK: - Private
    private let trailingActions: [SwipeAction]
    private let leadingActions: [SwipeAction]
    private let leadingFullSwipeIsEnabled = true
    private let trailingFullSwipeIsEnabled = false

    @State private var vibrationService: any VibrationServiceProtocol = VibrationService()

    @State private var offset: CGFloat = 0
    @State private var cachedOffset: CGFloat = 0
    @GestureState private var isDragging = false

    @State var font: Font

    let trailingViewWidth: CGFloat
    let leadingViewWidth: CGFloat

    @State private var contentWidth: CGFloat = 0
    @State private var swipeDirection: SwipeDirection = .left
    @State private var userNotified = false

    private let actionWidth: CGFloat

    init(leadingActions: [SwipeAction],
         trailingActions: [SwipeAction],
         font: Font?,
         actionWidth: CGFloat? = nil) {
        self.trailingActions = trailingActions
        self.leadingActions = leadingActions
        self.font = font ?? .caption
        
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
                            swipeDirection = offset >= 0 ? .right : .left
                            if (-offset > trailingViewWidth + actionWidth), !userNotified {
                                userNotified = true
                                vibrationService.vibrate()
                            } else if !trailingOversized, userNotified {
                                userNotified = false
                            }
                        }
                        .onEnded { value in
                            let dragThreshold = actionWidth * CGFloat(trailingActions.count) / 2
                            if -offset > dragThreshold {
                                if -offset > trailingViewWidth + actionWidth {
                                    trailingActions.first?.action()
                                    resetOffset()
                                } else {
                                    offset = -actionWidth * CGFloat(trailingActions.count)
                                }
                            } else {
                                offset = 0
                            }
                            cachedOffset = offset
                            let _ = print("offset:", offset)
                        }
                )
                .background(alignment: .trailing) {
                    if swipeDirection == .left {
                        trailingActionsView
                    }
                }
        }
        .clipped()
        .mask { content }
    }

    // MARK: - Private

    @ViewBuilder
    private var trailingActionsView: some View {
        if !trailingActions.isEmpty {
            HStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(trailingActions.first?.color ?? .clear)
                    .frame(width: 20)
                ForEach(trailingActions) { action in
                    let isLeftOne = trailingActions[0].id == action.id
                    Button {
                        action.action()
                        withAnimation { resetOffset() }
                    } label: {
                        ZStack {
                            if let icon = action.icon {
                                Image(uiImage: icon)
                                    .renderingMode(.template)
                            } else if let title = action.title {
                                Text(title)
                                    .cornerRadius(10)
                            } else {
                                Text("Error")
                            }
                        }
                        .minimumScaleFactor(0.3)
                        .font(font)
                        .padding(.horizontal)
                        .foregroundStyle(.white)
                        .frame(maxWidth: !isLeftOne ? actionWidth :
                                trailingOversized ? trailingHoldWidth : actionWidth)
                        .frame(maxHeight: .infinity)
                        .background(action.color)
                    }
                    .animation(nil, value: UUID())
                }
            }
            .frame(alignment: .trailing)
            .offset(x: max(0, offset))
            .background { trailingActions.first?.color ?? .clear }
        }
    }

    private var trailingHoldWidth: CGFloat {
        let rightSideActionsWidth = CGFloat(trailingActions.count - 1) * actionWidth
        let result = -offset - rightSideActionsWidth
        return result
    }

    private var trailingOversized: Bool {
        return offset <= -trailingViewWidth
    }

    private func resetOffset() {
        withAnimation(.spring()) {
            offset = 0
            cachedOffset = 0
            userNotified = false
        }
    }
}
