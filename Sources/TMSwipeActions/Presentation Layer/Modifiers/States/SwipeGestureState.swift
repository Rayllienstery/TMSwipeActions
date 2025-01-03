//
//  SwipeGestureState.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 27.12.2024.
//

import SwiftUI
import Combine

class SwipeGestureState: ObservableObject {
    @Published var offset: CGFloat = 0
    @Published var cachedOffset: CGFloat = 0
    @Published var swipeDirection: SwipeEdge = .trailing
    @Published var overdragged: Bool = false // Responsible for the width of the closest to the border button

    func setNewOffset(_ newValue: CGFloat, contentSize: CGFloat, safeWidth: CGFloat, fullSwipeIsEnabled: Bool) {
        self.offset = newValue
        self.swipeDirection = offset >= 0 ? .leading : .trailing
        
        let newOverdraggedValue = fullSwipeIsEnabled ? abs(offset) >= contentSize + safeWidth : false
        if newOverdraggedValue != self.overdragged {
            withAnimation {
                self.overdragged.toggle()
            }
        }
    }
}
