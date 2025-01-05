//
//  SwipeActionsViewConfig.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 27.12.2024.
//

import SwiftUI

public class SwipeActionsViewConfig {
    // Static
    public static let defaultActionWidth: CGFloat = 70

    let leadingFullSwipeIsEnabled: Bool
    let trailingFullSwipeIsEnabled: Bool

    let actionWidth: CGFloat

    let font: Font

    public init(leadingFullSwipeIsEnabled: Bool = true,
                trailingFullSwipeIsEnabled: Bool = true,
                actionWidth: CGFloat = SwipeActionsViewConfig.defaultActionWidth,
                font: Font = .caption) {
        self.leadingFullSwipeIsEnabled = leadingFullSwipeIsEnabled
        self.trailingFullSwipeIsEnabled = trailingFullSwipeIsEnabled
        self.actionWidth = actionWidth
        self.font = font
    }
}
