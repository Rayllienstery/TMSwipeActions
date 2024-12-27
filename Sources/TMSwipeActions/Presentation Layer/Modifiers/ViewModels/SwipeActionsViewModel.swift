//
//  SwipeActionsViewModel.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 27.12.2024.
//
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
