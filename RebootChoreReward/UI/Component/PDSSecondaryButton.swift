//
//  PDSSecondaryButton.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class PDSSecondaryButton: UIButton, Themable {
    init() {
        super.init(frame: .zero)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        ThemeManager.shared.register(self)
    }
    
    // If you want to change the appearance when the button is highlighted,
    // you can override the isHighlighted property and update the configuration accordingly.
    override var isHighlighted: Bool {
        didSet {
            applyTheme(ThemeManager.shared.currentTheme) // Re-apply the configuration to update the background color transformer
        }
    }
    
    func applyTheme(_ theme: PDSTheme) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = theme.color.surfaceColor
        config.baseForegroundColor = theme.color.onSurface
        config.cornerStyle = .large
        config.title = self.title(for: .normal)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = theme.typography.button
            return outgoing
        }
        config.imagePadding = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

        // Customizing the button for the `.highlighted` state
        config.background.backgroundColorTransformer = UIConfigurationColorTransformer { _ in
            return self.isHighlighted ? UIColor.darkGray : UIColor.systemBackground
        }

        // Custom shadow properties can be added via layer because UIButton.Configuration does not directly support shadows
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 3
        layer.shadowOpacity = 0.4
        
        layer.borderColor = theme.color.secondaryColor.cgColor
        layer.borderWidth = 1.0
        
        layer.cornerRadius = theme.styling.cornerRadius
        
        self.configuration = config
    }
}


struct PDSSecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreviewWrapper {
            let button = PDSSecondaryButton()
            button.setTitle("Secondary Button", for: .normal)
            return button
        }
        .fixedSize()
        .previewLayout(.sizeThatFits)
    }
}

