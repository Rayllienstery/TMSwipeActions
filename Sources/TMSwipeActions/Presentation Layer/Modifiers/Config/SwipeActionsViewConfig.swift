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

    let animation: Animation? = .default

    let leadingFullSwipeIsEnabled: Bool
    let trailingFullSwipeIsEnabled: Bool

    let font: Font

    public init(leadingFullSwipeIsEnabled: Bool = true,
                trailingFullSwipeIsEnabled: Bool = true,
                font: Font = .caption) {
        self.leadingFullSwipeIsEnabled = leadingFullSwipeIsEnabled
        self.trailingFullSwipeIsEnabled = trailingFullSwipeIsEnabled
        self.font = font
    }
}
