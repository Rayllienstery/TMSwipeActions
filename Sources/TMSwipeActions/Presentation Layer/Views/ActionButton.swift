//
//  ActionButton.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 28.12.2024.
//

import SwiftUI

extension ActionsView {
    @ViewBuilder
    func actionButton(_ action: SwipeAction, _ theBorderedOne: Bool) -> some View {
        Button {
            action.action()
//            withAnimation(viewConfig.animation) { resetAction() }
            resetAction()
        } label: {
            actionButtonLabel(action, theBorderedOne)
        }
    }

    // MARK: - Private
    @ViewBuilder
    private func actionButtonLabel(_ action: SwipeAction, _ theBorderedOne: Bool) -> some View {
        HStack {
            if let icon = action.icon {
                Image(uiImage: icon)
                    .renderingMode(.template)
            } else if let title = action.title {
                Text(title)
                    .cornerRadius(10)
                    .lineLimit(1)
            } else {
                Text("Error")
            }
            if overdragged, theBorderedOne, fullSwipeIsEnabled {
                Spacer()
            }
        }
        .minimumScaleFactor(0.03)
        .font(font)
        .padding(.horizontal)
        .padding(.leading, overdragged ? 30 : 0)
        .foregroundStyle(.white)
        .frame(width: overdragged ? (theBorderedOne ? fullWidth : 0) : width)
        .frame(maxHeight: .infinity)
        .background(action.color)
        .clipped()
    }
}
