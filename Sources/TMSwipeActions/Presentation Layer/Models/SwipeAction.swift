//
//  SwipeAction.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 22.12.2024.
//

import SwiftUI

public struct SwipeAction: Identifiable {
    public let id: UUID = .init()
    let title: String?
    let icon: UIImage?
    let color: Color
    let action: () -> Void
    
    public init(title: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = nil
        self.color = color
        self.action = action
    }
    
    public init(icon: UIImage, color: Color, action: @escaping () -> Void) {
        self.title = nil
        self.icon = icon
        self.color = color
        self.action = action
    }
}
