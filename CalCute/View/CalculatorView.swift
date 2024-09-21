//
//  CalculatorView.swift
//  CalCute
//
//  Created by Otávio Augusto on 15/9/24.
//

import Foundation
import UIKit

final class CalculatorView: UIView {

	let buttonClickCallback: (Int) -> Void
	
	// ícone de coração
	private lazy var heartImage: UIImageView = {
		let configuration = UIImage.SymbolConfiguration(pointSize: 80, weight: .medium)
		let systemImage = UIImage(systemName: "heart.fill", withConfiguration: configuration)
		let uiImageView = UIImageView(image: systemImage)
		uiImageView.tintColor = .cutePinkHighlight
		uiImageView.layer.zPosition = 0
		uiImageView.translatesAutoresizingMaskIntoConstraints = false
		return uiImageView
	}()
	// botão transparente que responde os cliques pela imagem de coração
	private lazy var heartButton: UIButton = {
		let button = makeTextButton(text: "", tag: 34, color: .clear)
		button.layer.zPosition = 1
		return button
	}()
	// junção do botão transparente encima da imagem de coração
	private lazy var heartView: UIView = {
		let view = UIView()
		view.addSubview(heartImage)
		view.addSubview(heartButton)
		view.widthAnchor.constraint(equalToConstant: 85).isActive = true
		view.heightAnchor.constraint(equalToConstant: 85).isActive = true
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	// stackview principal que arranja os botões em tela
	private lazy var stackView: UIStackView = {
		let stackView = UIStackView(arrangedSubviews: [
			UIView(),
			buildView()
		])
		stackView.distribution = .equalSpacing
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()
	// visor que mostra os resultados
	private lazy var resultLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 70, weight: .regular)
		label.adjustsFontSizeToFitWidth = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	init(frame: CGRect, buttonClickCallback: @escaping (Int) -> Void) {
		self.buttonClickCallback = buttonClickCallback
		super.init(frame: frame)
		setupStackView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// usando stackviews, monta um layout com todos itens da view
	/// - Returns: view montada em stackview
	private func buildView() -> UIStackView {
		var horizontalStacks = [UIStackView]()
		horizontalStacks.append(makeHorizontalStack(with: [resultLabel]))
		horizontalStacks.append(
			makeHorizontalStack(with:
				[
					makeTextButton(text: "AC", tag: 20, doubleSize: true),
					makeIconButton(icon: "delete.left.fill", tag: 21),
					makeIconButton(icon: "divide", tag: 30),
				]))
		horizontalStacks.append(
			makeHorizontalStack(with:
				[
					makeTextButton(text: "7", tag: 7),
					makeTextButton(text: "8", tag: 8),
					makeTextButton(text: "9", tag: 9),
					makeIconButton(icon: "minus", tag: 31),
				]))
		horizontalStacks.append(
			makeHorizontalStack(with:
				[
				makeTextButton(text: "4", tag: 4),
				makeTextButton(text: "5", tag: 5),
				makeTextButton(text: "6", tag: 6),
				makeIconButton(icon: "plus", tag: 32),
				]))
		horizontalStacks.append(
			makeHorizontalStack(with:
				[
				makeTextButton(text: "1", tag: 1),
				makeTextButton(text: "2", tag: 2),
				makeTextButton(text: "3", tag: 3),
				makeIconButton(icon: "multiply", tag: 33),
				]))
		horizontalStacks.append(makeHorizontalStack(with:
				[
					makeTextButton(text: "0", tag: 0, doubleSize: true),
				makeTextButton(text: ",", tag: 10),
				heartView,
				]))
		return makeVerticalStack(with: horizontalStacks)
	}
	
	/// 	monta uma stackview horizontal semelhante a HStack de swiftUI
	/// - Parameter views: views que deseja incluir na stackview
	/// - Returns: retorna stack view montada
	private func makeHorizontalStack(with views: [UIView]) -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: views)
		stackView.distribution = .equalSpacing
		stackView.axis = .horizontal
		stackView.alignment = .fill
		stackView.widthAnchor.constraint(equalToConstant: 350).isActive = true
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}
	
	/// 	monta uma stackview vertical semelhante a VStack de swiftUI
	/// - Parameter views: views que deseja incluir na stackview
	/// - Returns: retorna stack view montada
	private func makeVerticalStack(with views: [UIView]) -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: views)
		stackView.spacing = 10
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}
	
	
	/// cria um botão com somente texto
	/// - Parameters:
	///   - text: texto do botão
	///   - tag: tag do botão
	///   - color: cor  do botão
	///   - doubleSize: booleano para caso queira um botão 2x1 ou 1x1
	/// - Returns: retorna botão montado
	private func makeTextButton(text: String, tag: Int, color: UIColor = .cutePinkPrimary, doubleSize: Bool = false) -> UIButton {
		let button = UIButton()
		button.setTitle(text, for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 40, weight: .regular)
		configureButtonAppearance(button: button, tag: tag, color: color, doubleSize: doubleSize)
		return button
	}
	
	/// cria botão com somente um ícone
	/// - Parameters:
	///   - icon: ícone do botão
	///   - tag: tag do botão
	///   - color: cor  do botão
	/// - Returns: retorna botão montado
	private func makeIconButton(icon: String, tag: Int, color: UIColor = .cutePinkPrimary) -> UIButton {
		let button = UIButton()
		let configuration = UIImage.SymbolConfiguration(pointSize: 40, weight: .regular)
		button.setImage(UIImage(systemName: icon)?.applyingSymbolConfiguration(configuration), for: .normal)
		button.tintColor = .white
		configureButtonAppearance(button: button, tag: tag, color: color)
		return button
	}
	
	/// configura atributos especificos do botão que são comuns para ambos botões
	/// - Parameters:
	///   - button: botão a ser configurado
	///   - tag: tag do botão
	///   - color: cor do botão
	///   - doubleSize: booleano para caso queira um botão 2x1 ou 1x1
	private func configureButtonAppearance(button: UIButton, tag: Int, color: UIColor, doubleSize: Bool = false) {
		button.tag = tag
		button.backgroundColor = color
		button.heightAnchor.constraint(equalToConstant: 85).isActive = true
		button.widthAnchor.constraint(equalToConstant: doubleSize ? 170 : 85).isActive = true
		button.layer.cornerRadius = 40
		button.clipsToBounds = true
		button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
		button.translatesAutoresizingMaskIntoConstraints = false
	}
	
	/// adiciona constraints para a stackview
	private func setupStackView() {
		addSubview(stackView)
		NSLayoutConstraint.activate([
			stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
			stackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
		])
	}
	
	/// atualiza a stackview com o dado informado pela viewController
	/// - Parameter value: valor a ser atribuido para a resultLabel
	func updateResultLabel(with value: String) {
		resultLabel.text = value
	}
	
	/// handler para quando o botão for pressionado
	/// - Parameter sender: quem apertou o botão
	@objc func buttonTapped(_ sender: UIButton) {
		heartImage.addSymbolEffect(.bounce)
		buttonClickCallback(sender.tag)
	}
}
