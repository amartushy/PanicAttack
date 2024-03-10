//
//  Functions.swift
//  locale
//
//  Created by Adrian Martushev on 2/24/24.
//

import Foundation
import UIKit





func getInitials(fullName : String) -> String {
    let names = fullName.split(separator: " ")

    switch names.count {
    case 0:
        return ""
    case 1:
        // Only one name provided
        return String(names.first!.prefix(1))
    default:
        // Two or more names provided, get the first and last name initials
        let firstInitial = names.first!.prefix(1)
        let lastInitial = names.last!.prefix(1)
        print("\(firstInitial)\(lastInitial)")
        return "\(firstInitial)\(lastInitial)"
    }
}






func generateHapticFeedback() {
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.prepare()
    generator.impactOccurred()
}
