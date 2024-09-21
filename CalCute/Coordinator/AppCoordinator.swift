//
//  Coordinator.swift
//  CalCute
//
//  Created by Otávio Augusto on 15/9/24.
//
import UIKit

final class AppCoordinator {
	let rootController: UINavigationController
	
	init(rootController: UINavigationController) {
		self.rootController = rootController
	}
	
	func start() {
		let controller = CalculatorController()
		rootController.pushViewController(controller, animated: true)
	}
}
