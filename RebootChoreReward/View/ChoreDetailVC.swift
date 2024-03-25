
//  ChoreDetailVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 3/21/24.
//

import SwiftUI
import UIKit
import Combine

class ChoreDetailVC: UIViewController {
    private var viewModel: ChoreDetailViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let swipableImageRowVC = PDSSwipableImageRowVC()

    private let titleLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .headline1, textColor: PDSTheme.defaultTheme.color.secondaryColor)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: PDSLabel = {
        let label = PDSLabel(withText: "Description", fontScale: .caption, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionDetailLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rewardLabel: PDSLabel = {
        let label = PDSLabel(withText: "Reward", fontScale: .caption, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let rewardAmountLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdByLabel: PDSLabel = {
        let label = PDSLabel(withText: "Created by", fontScale: .caption, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let creatorLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdOnLabel: PDSLabel = {
        let label = PDSLabel(withText: "on", fontScale: .caption, textColor: PDSTheme.defaultTheme.color.onSurface)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let createdDateLabel: PDSLabel = {
        let label = PDSLabel(withText: "", fontScale: .body, textColor: PDSTheme.defaultTheme.color.onSurface)
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
        viewModel.$chore
            .receive(on: RunLoop.main)
            .sink { [weak self] chore in
                self?.titleLabel.text = chore.name
                self?.descriptionDetailLabel.text = chore.description
                self?.rewardAmountLabel.text = String(format: "$%.2f", chore.rewardAmount)
                self?.swipableImageRowVC.imageUrls = chore.imageUrls
                self?.creatorLabel.text = chore.creator
                self?.createdDateLabel.text = chore.createdDate.toRelativeString()
            }
            .store(in: &cancellables)
    }

    private func setUpViews() {
        view.backgroundColor = PDSTheme.defaultTheme.color.surfaceColor
        guard let swipableImageRow = swipableImageRowVC.view else {
            return
        }
        
        let vStack = UIStackView(arrangedSubviews: [
            titleLabel,
            UIView.createSpacerView(height: 20),
            swipableImageRow,
            UIView.createSpacerView(height: 20),
            descriptionLabel,
            UIView.createSpacerView(height: 10),
            descriptionDetailLabel,
            UIView.createSpacerView(height: 20),
            rewardLabel,
            UIView.createSpacerView(height: 10),
            rewardAmountLabel,
            UIView.createSpacerView(height: 20),
            createdByLabel,
            UIView.createSpacerView(height: 10),
            creatorLabel,
            UIView.createSpacerView(height: 20),
            createdOnLabel,
            UIView.createSpacerView(height: 10),
            createdDateLabel
        ])
        vStack.axis = .vertical
        vStack.distribution = .equalSpacing
        vStack.alignment = .center
        vStack.spacing = 0
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(vStack)
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            swipableImageRow.heightAnchor.constraint(equalToConstant: 300),
            swipableImageRow.leadingAnchor.constraint(equalTo: vStack.leadingAnchor),
            swipableImageRow.trailingAnchor.constraint(equalTo: vStack.trailingAnchor)
            
        ])
    }

    private func setUpActions() {
        
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
 
