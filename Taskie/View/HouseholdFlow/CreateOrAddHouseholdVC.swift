
//  CreateOrAddHouseholdVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 5/1/24.
//

import SwiftUI
import UIKit

class CreateOrAddHouseholdVC: PDSTitleWrapperVC {
    private var viewModel: CreateOrAddHouseholdViewModel
    private let dependencyView: Dependency.View
    
    private let promptCreateHouseholdLabel: PDSLabel = {
        let label = PDSLabel(withText: "If this is your first time you and your family is using Taskie, please create a Household.", fontScale: .caption)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createNewHouseholdButton: PDSPrimaryButton = {
        let button = PDSPrimaryButton()
        button.setTitle("Create new Household", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let promptSearchHouseholdLabel: PDSLabel = {
        let label = PDSLabel(withText: "Otherwise, you can request to join an existing Household of your family.", fontScale: .caption)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchExistingHouseholdButton: PDSSecondaryButton = {
        let button = PDSSecondaryButton()
        button.setTitle("Search for Household", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(
        viewModel: CreateOrAddHouseholdViewModel,
        dependencyView: Dependency.View
    ) {
        self.viewModel = viewModel
        self.dependencyView = dependencyView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUpActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        hideLoadingIndicator()
    }
    
    private func setUpViews() {
        setTitle("Let's get started!")
        
        let vStack = UIStackView.vStack(
            arrangedSubviews: [
                promptCreateHouseholdLabel,
                UIView.createSpacerView(height: 20),
                createNewHouseholdButton,
                UIView.createSpacerView(height: 40),
                UIView.createSeparatorView(),
                UIView.createSpacerView(height: 20),
                promptSearchHouseholdLabel,
                UIView.createSpacerView(height: 20),
                searchExistingHouseholdButton
            ],
            alignment: .center,
            shouldExpandSubviewWidth: true
        )
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        
        NSLayoutConstraint.activate([
            vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func setUpActions() {
        createNewHouseholdButton.addTarget(self, action: #selector(handleCreateNewHousehold), for: .touchUpInside)
    }
    
    @objc private func handleCreateNewHousehold() {
        let createHouseholdVC = self.dependencyView.createHouseholdVC()
        navigationController?.pushViewController(createHouseholdVC, animated: true)
    }
}

struct CreateOrAddHouseholdVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.createOrAddHouseholdVC()
        }
    }
}

extension Dependency.View {
    func createOrAddHouseholdVC() -> CreateOrAddHouseholdVC {
        return CreateOrAddHouseholdVC(
            viewModel: viewModel.createOrAddHouseholdViewModel(),
            dependencyView: self
        )
    }
}
