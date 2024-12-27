//
//  VibrationService.swift
//  TMSwipeActions
//
//  Created by Kostiantyn Kolosov on 22.12.2024.
//

import SwiftUI

protocol VibrationServiceProtocol: ObservableObject {
    func vibrate()
}

class VibrationService: VibrationServiceProtocol {
    func vibrate() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
