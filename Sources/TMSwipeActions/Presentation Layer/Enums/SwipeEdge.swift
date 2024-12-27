//
//  SwipeDirection.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 22.12.2024.
//

import SwiftUI

enum SwipeEdge {
    case trailing
    case leading

    var alignment: Alignment {
        switch self {
        case .trailing: .trailing
        case .leading: .leading
        }
    }
}
