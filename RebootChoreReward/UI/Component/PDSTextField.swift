//
//  PDSTextField.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/25/24.
//

import UIKit
import SwiftUI

class PDSTextField: UITextField, Themable {
    var normalBorderColor = UIColor.gray.cgColor
    var highlightedBorderColor = UIColor.systemBlue.cgColor
    
    let normalBorderWidth: CGFloat = 1.0
    let highlightedBorderWidth: CGFloat = 3.0
    
    let placeholderText: String
    var textPadding = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    
    init(withPlaceholder placeholderText: String) {
        self.placeholderText = placeholderText
        super.init(frame: .zero)
        configureTextField()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextField() {
        ThemeManager.shared.register(self)
    }
    
    override func becomeFirstResponder() -> Bool {
        let becomeActive = super.becomeFirstResponder()
        if becomeActive {
            // Highlight the border when textField is focused
            layer.borderColor = highlightedBorderColor
            layer.borderWidth = highlightedBorderWidth
        }
        return becomeActive
    }
    
    override func resignFirstResponder() -> Bool {
        let resignActive = super.resignFirstResponder()
        if resignActive {
            // Revert to the normal border when textField is not focused
            layer.borderColor = normalBorderColor
            layer.borderWidth = normalBorderWidth
        }
        return resignActive
    }
    
    // MARK: - Padding Overrides
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
    
    func applyTheme(_ theme: PDSTheme) {
        normalBorderColor = theme.color.darkenPrimaryColor.cgColor
        highlightedBorderColor = theme.color.primaryColor.cgColor
        font = theme.typography.body
        placeholder = placeholderText
        autocorrectionType = .no
        layer.borderColor = normalBorderColor
        layer.borderWidth = normalBorderWidth
        layer.cornerRadius = 10 // Adjust for desired corner radius
        
    }
}

struct PDSTextField_Previews: PreviewProvider {
    static var previews: some View {
        UIViewPreviewWrapper {
            let textField = PDSTextField(withPlaceholder: "Password")
            return textField
        }
        .fixedSize()
        .previewLayout(.sizeThatFits)
    }
}
