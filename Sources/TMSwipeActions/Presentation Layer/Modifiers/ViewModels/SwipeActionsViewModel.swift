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

    init(trailingActions: [SwipeAction], leadingActions: [SwipeAction]) {
        self.trailingActions = trailingActions
        self.leadingActions = leadingActions
    }
}
