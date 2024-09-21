//
//  ViewRepresentable.swift
//  CalCute
//
//  Created by Otávio Augusto on 15/9/24.
//

import UIKit
import SwiftUI

struct StartViewRepresentable: UIViewControllerRepresentable {
	func makeUIViewController(context: Context) -> UINavigationController {
		let navigationController = UINavigationController()
		let coordinator = AppCoordinator(rootController: navigationController)
		coordinator.start()
		return navigationController
	}
	
	func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
		
	}
	
}

#Preview {
	StartViewRepresentable()
}
