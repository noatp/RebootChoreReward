
//  ChoreDetailVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import SwiftUI
import UIKit
import Combine

class ChoreDetailVC: PDSTitleWrapperVC {
    private var viewModel: ChoreDetailViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let swipableImageRowVC = PDSSwipableImageRowVC()
    
    private let backBarButton: PDSTertiaryButton = {
        let button = PDSTertiaryButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let descriptionLabel: PDSLabel = {
        let label = PDSLabel(withText: "Description", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionDetailLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rewardLabel: PDSLabel = {
        let label = PDSLabel(withText: "Reward", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rewardAmountLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdByLabel: PDSLabel = {
        let label = PDSLabel(withText: "Created by", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let creatorLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdOnLabel: PDSLabel = {
        let label = PDSLabel(withText: "on", fontScale: .caption)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(
        viewModel: ChoreDetailViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        addChild(swipableImageRowVC)
        swipableImageRowVC.didMove(toParent: self)
        setUpViews()
        setUpActions()
    }
    
    private func bindViewModel() {
        viewModel.$choreDetailForView
            .receive(on: RunLoop.main)
            .sink { [weak self] chore in
                self?.setTitle(chore.name)
                self?.descriptionDetailLabel.text = chore.description
                self?.rewardAmountLabel.text = String(format: "$%.2f", chore.rewardAmount)
                self?.swipableImageRowVC.imageUrls = chore.imageUrls
                self?.creatorLabel.text = chore.creatorName
                self?.createdDateLabel.text = chore.createdDate
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        ThemeManager.shared.register(self)
        
        guard let swipableImageRow = swipableImageRowVC.view else {
            return
        }
        
        let vStack = UIStackView.vStack(arrangedSubviews: [
            swipableImageRow,
            .createSpacerView(height: 20),
            descriptionLabel,
            .createSpacerView(height: 10),
            descriptionDetailLabel,
            .createSpacerView(height: 20),
            rewardLabel,
            .createSpacerView(height: 10),
            rewardAmountLabel,
            .createSpacerView(height: 20),
            createdByLabel,
            .createSpacerView(height: 10),
            creatorLabel,
            .createSpacerView(height: 20),
            createdOnLabel,
            .createSpacerView(height: 10),
            createdDateLabel
        ], alignment: .center)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: titleBottomAnchor, constant: 40),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            swipableImageRow.heightAnchor.constraint(equalToConstant: 300),
            swipableImageRow.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            swipableImageRow.trailingAnchor.constraint(equalTo: vStack.trailingAnchor)
            
        ])
    }

    private func setUpActions() {
        backBarButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarButton)
    }
    
    override func applyTheme(_ theme: PDSTheme) {
        super.applyTheme(theme)
        view.backgroundColor = theme.color.surfaceColor
    }
    
    @objc func handleBack() {
        self.dismiss(animated: true)
    }
}

struct ChoreDetailVC_Previews: PreviewProvider {
    static var previews: some View {
        UIViewControllerPreviewWrapper {
            Dependency.preview.view.choreDetailVC()
        }
    }
}

extension Dependency.View {
    func choreDetailVC() -> ChoreDetailVC {
        return ChoreDetailVC(viewModel: viewModel.choreDetailViewModel())
    }
}
 
