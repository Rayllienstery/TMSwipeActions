//
//  SwiftUIView.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 27.12.2024.
//

// TODO: - Fluid to the end

import SwiftUI

struct ActionsView: View {
    @Binding var viewConfig: SwipeActionsViewConfig

    @Binding var actions: [SwipeAction]
    @Binding var offset: CGFloat
    @Binding var overdragged: Bool
    @Binding var containerWidth: CGFloat

    @State var swipeEdge: SwipeEdge

    @State var width: CGFloat = 0
    @State var fullWidth: CGFloat = 0

    var font: Font
    var actionWidth: CGFloat

    let resetAction: () -> Void

    var fullSwipeIsEnabled: Bool {
        swipeEdge == .leading ? viewConfig.leadingFullSwipeIsEnabled : viewConfig.trailingFullSwipeIsEnabled
    }

    var body: some View {
        if !actions.isEmpty {
            Spacer()
            HStack(spacing: 0) {
                ForEach(actions) { action in
                    let theBorderedOne = theBorderedOne(action)
                    actionButton(action, theBorderedOne)
                }
            }
            .frame(width: containerWidth, alignment: swipeEdge.alignment)
//            .animation(viewConfig.animation, value: overdragged) // After overdragged
//            .animation(viewConfig.animation, value: width != 0) // After tap gesture
            .background { backgroundColor }
            .onChange(of: offset) { newValue in
                self.width = actionWidthValue
                self.fullWidth = abs(offset) + 30
            }
        }
    }

    private var actionWidthValue: CGFloat {
        let actionsCount = CGFloat(actions.count)
        let offset = abs(offset)
        switch overdragged {
        case true:
            return offset / actionsCount
        case false:
            return offset / actionsCount
        }
    }
    
    private func theFirstOne(_ action: SwipeAction) -> Bool {
        guard !actions.isEmpty else { return false }
        switch swipeEdge {
        case .trailing:
            return action.id == actions.first!.id
        case .leading:
            return action.id == actions.last!.id
        }
    }

    private func theBorderedOne(_ action: SwipeAction) -> Bool {
        guard !actions.isEmpty else { return false }
        switch swipeEdge {
        case .trailing:
            return action.id == actions.last!.id
        case .leading:
            return action.id == actions.first!.id
        }
    }
    
    private var backgroundColor: Color {
        switch swipeEdge {
        case .trailing: actions.first?.color ?? .clear
        case .leading: actions.last?.color ?? .clear
        }
    }
}
