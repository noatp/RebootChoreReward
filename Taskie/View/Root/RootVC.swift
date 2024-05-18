//
//  RootVC.swift
//  RebootChoreReward
//
//  Created by Toan Pham on 2/19/24.
//

import UIKit
import Combine

class RootVC: UIViewController {
    private var viewModel: RootViewModel
    private var cancellables: Set<AnyCancellable> = []
    private var dependencyView: Dependency.View
    private var current: UINavigationController
    
    init(viewModel: RootViewModel, dependencyView: Dependency.View) {
        self.viewModel = viewModel
        self.dependencyView = dependencyView
        self.current = UINavigationController(rootViewController: dependencyView.landingVC())
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        addChild(current)
        current.didMove(toParent: self)
        setUpViews()
    }
    
    private func setUpViews() {
        view.backgroundColor = .systemBackground
        
        guard let childView = current.view else {
            return
        }
        childView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(childView)
        setupConstraints(for: childView)
    }
    
    private func bindViewModel() {
        viewModel.$hasUserData
            .combineLatest(viewModel.$hasHouseholdData)
            .combineLatest(viewModel.$hasUserName)
            .combineLatest(viewModel.$hasProfileColor)
            .receive(on: RunLoop.main)
            .sink { [weak self] (arg0, hasProfileColor) in
                
                let ((hasUserData, hasHouseholdData), hasUserName) = arg0
                LogUtil.log("From RootViewModel -- hasUserData -- \(hasUserData)")

                guard let self = self else {
                    return
                }
                
                if hasUserData {
                    if !hasUserName {
                        let enterNameVC = self.dependencyView.enterNameVC()
                        let navVC = UINavigationController(rootViewController: enterNameVC)
                        self.switchToViewController(navVC)
                    }
                    else if !hasProfileColor {
                        let pickProfileColorVC = self.dependencyView.pickProfileColorVC()
                        let navVC = UINavigationController(rootViewController: pickProfileColorVC)
                        self.switchToViewController(navVC)
                    }
                    else if hasHouseholdData {
                        let choreListVC = self.dependencyView.choreListVC()
                        let navVC = UINavigationController(rootViewController: choreListVC)
                        self.switchToViewController(navVC)
                    }
                    else {
                        let createOrAddHouseholdVC = self.dependencyView.createOrAddHouseholdVC()
                        let navVC = UINavigationController(rootViewController: createOrAddHouseholdVC)
                        self.switchToViewController(navVC)
                    }
                }
                else {
                    let landingVC = self.dependencyView.landingVC()
                    let navVC = UINavigationController(rootViewController: landingVC)
                    self.switchToViewController(navVC)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: RunLoop.main)
            .sink { [weak self] errorMessage in
                LogUtil.log("from RootViewModel -- errorMessage -- \(errorMessage)")
                if let errorMessage = errorMessage {
                    DispatchQueue.main.async { [weak self] in
                        self?.displayErrorMessage(errorMessage)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func displayErrorMessage(_ errorMessage: String) {
        switch errorMessage {
            case AuthServiceError.emailAlreadyInUse.localizedDescription:
                self.showAlert(withTitle: "Email already in use", alertMessage: errorMessage, buttonTitle: "Log in"){
                    self.current.popToRootViewController(animated: false)
                    if let landingVC = self.current.viewControllers.first as? LandingVC {
                        landingVC.navigateToLogIn()
                    }
                }
            default:
                ErrorWindow.shared.showAlert(alertMessage: errorMessage)
        }
    }
    
    private func switchToViewController(_ newVC: UINavigationController) {
        guard let newRoot = newVC.viewControllers.first,
              let oldRoot = current.viewControllers.first,
              type(of: newRoot) != type(of: oldRoot) 
        else{
            return
        }
        let oldVC = current
        // Prepare the new view controller
        addChild(newVC)
        newVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newVC.view)
        setupConstraints(for: newVC.view)
        newVC.didMove(toParent: self)
        oldVC.willMove(toParent: nil)
        oldVC.view.removeFromSuperview()
        oldVC.removeFromParent()
        
        // Update the current view controller reference
        current = newVC
    }
    
    private func setupConstraints(for childView: UIView) {
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childView.topAnchor.constraint(equalTo: view.topAnchor),
            childView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension RootVC {
    func getTopVC() -> UIViewController? {
        if let topController = current.topViewController {
            return topController
        }
        return nil
    }
}

extension Dependency.View {
    func rootVC() -> RootVC {
        return RootVC(
            viewModel: viewModel.rootViewModel(),
            dependencyView: self
        )
    }
}
