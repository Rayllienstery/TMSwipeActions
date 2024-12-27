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

    public init(leadingFullSwipeIsEnabled: Bool = true,
                trailingFullSwipeIsEnabled: Bool = true) {
        self.leadingFullSwipeIsEnabled = leadingFullSwipeIsEnabled
        self.trailingFullSwipeIsEnabled = trailingFullSwipeIsEnabled
    }
}
