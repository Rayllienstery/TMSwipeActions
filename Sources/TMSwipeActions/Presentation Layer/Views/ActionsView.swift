//
//  SwiftUIView.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 27.12.2024.
//

import SwiftUI

struct ActionsView: View {
    @Binding var actions: [SwipeAction]
    @Binding var offset: CGFloat
    @Binding var overdragged: Bool

    @State var swipeEdge: SwipeEdge

    var font: Font
    var actionWidth: CGFloat

    let resetAction: () -> Void

    var body: some View {
        if !actions.isEmpty {
            HStack(spacing: 0) {
                trailingSpacer
                ForEach(actions) { action in
                    Button {
                        action.action()
                        withAnimation { resetAction() }
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
                        .frame(width: actionWidth)
                        //                        .frame(maxWidth: !isLeftOne ? actionWidth :
                        //                                trailingOversized ? trailingHoldWidth : actionWidth)
                        .frame(maxHeight: .infinity)
                        .background(action.color)
                    }
                }
                leadingSpacer
            }
            .frame(alignment: swipeEdge.alignment)
            .background { backgroundColor }
        }
    }

    @ViewBuilder
    private var trailingSpacer: some View {
        if swipeEdge == .trailing {
            Spacer()
            Rectangle()
                .fill(actions.first?.color ?? .clear)
                .frame(width: 20)
        }
    }

    @ViewBuilder
    private var leadingSpacer: some View {
        if swipeEdge == .leading {
            Spacer()
            Rectangle()
                .fill(actions.last?.color ?? .clear)
                .frame(width: 20)
        }
    }

    private func isBorderedOne(_ action: SwipeAction) -> Bool {
        guard !actions.isEmpty else { return false }
        switch swipeEdge {
        case .trailing:
            return action.id == actions[0].id
        case .leading:
            return action.id == actions.last!.id
        }
    }

    private var backgroundColor: Color {
        switch swipeEdge {
        case .trailing: actions.first?.color ?? .clear
        case .leading: actions.last?.color ?? .clear
        }
    }
}
