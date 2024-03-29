//
//  ThemeManager.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/26/24.
//

import UIKit

protocol Themable {
    func applyTheme(_ theme: PDSTheme)
}

struct PDSStyling {
    var cornerRadius: CGFloat
    static let defaultStyling = PDSStyling(cornerRadius: 10)
}

struct PDSColor {
    var primaryColor: UIColor
    var darkenPrimaryColor: UIColor
    var secondaryColor: UIColor
    var darkenSecondaryColor: UIColor
    var backgroundColor: UIColor
    var surfaceColor: UIColor
    var errorColor: UIColor
    var onPrimary: UIColor
    var onSecondary: UIColor
    var onBackground: UIColor
    var onSurface: UIColor
    var onError: UIColor
    var highlightColor: UIColor
    var dividerColor: UIColor

    // Add more theme attributes as needed
    
    // Define default and other themes
    static let lightModeColors = PDSColor(
        primaryColor: .init(hex: "#87cefa"),
        darkenPrimaryColor: .init(hex: "#6CA5C8"),
        secondaryColor: .init(hex: "#4169E1"),
        darkenSecondaryColor: .init(hex: "#3454B4"),
        backgroundColor: .init(hex: "#f5f5f5"),
        surfaceColor: .init(hex: "#ffffff"),
        errorColor: .init(hex: "#f44336"),
        onPrimary: .init(hex: "#000000"),
        onSecondary: .init(hex: "#ffffff"),
        onBackground: .init(hex: "#000000"),
        onSurface: .init(hex: "#000000"),
        onError: .init(hex: "#ffffff"),
        highlightColor: .init(hex: "#A0E8FF"),
        dividerColor: .init(hex: "#e0e0e0")
    )
}

struct PDSTheme {
    var color: PDSColor
    var typography: PDSTypography
    var styling: PDSStyling
    
    static let defaultTheme = PDSTheme(color: .lightModeColors, typography: .defaultTypography, styling: .defaultStyling)
}


class ThemeManager {
    static let shared = ThemeManager()

    private(set) var currentTheme: PDSTheme = .defaultTheme {
        didSet {
            // Notify all registered components about the theme change
            for component in themableComponents {
                component.applyTheme(currentTheme)
            }
        }
    }

    private var themableComponents = [Themable]()

    func register(_ component: Themable) {
        themableComponents.append(component)
        component.applyTheme(currentTheme) // Apply current theme immediately
    }
    
    
    
    // Add methods to switch themes as needed
    func switchToTheme(_ theme: PDSTheme) {
        currentTheme = theme
    }
}

