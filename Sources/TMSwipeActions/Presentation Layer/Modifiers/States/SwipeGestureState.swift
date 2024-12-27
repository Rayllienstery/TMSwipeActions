//
//  SwipeGestureState.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 27.12.2024.
//

import SwiftUI

class SwipeGestureState: ObservableObject {
    @Published var offset: CGFloat = 0
    @Published var cachedOffset: CGFloat = 0
    @Published var swipeDirection: SwipeEdge = .trailing
    @Published var overdragged: Bool = false // Responsible for the width of the closest to the border button
}
