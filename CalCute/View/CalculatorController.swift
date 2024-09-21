//
//  CalculatorControler.swift
//  CalCute
//
//  Created by Otávio Augusto on 15/9/24.
//
import UIKit

final class CalculatorController: UIViewController {
	
	private lazy var calculatorView = CalculatorView(
		frame: .zero,
		buttonClickCallback: { [weak self] tag in
			guard let self else { return }
			buttonPressed(tag: tag)
		}
	)
	
	private enum ErrorCases: String {
		case invalidExpression = "expressão inválida"
		case infiniteNumber = "número infinito"
		case invalidNumber = "resultado inválido"
		case unknownOperation = "operação desconhecida"
	}
	
	// padrão de expressão a ser seguido
	private let expressionRegexPattern = #"^\d+(\.\d+)?([+\-*/]\d+(\.\d+)?)*$"#
	// expressão para calculo da controller
	private var expression = ""
	// expressão amigável que será visualziada pelo usuário
	private var screenExpression = "" {
		didSet {
			updateView(with: screenExpression)
		}
	}
	// define se o botão de ponto flutuante está ativado ou não
	private var isPointActive = false
	
	override func viewDidLoad() {
		view = calculatorView
	}
	
	/// Callback para toda vez que um botão é pressionado
	/// - Parameter tag: tag do botão pressionado
	private func buttonPressed(tag: Int) {
		updateExpressions(tag: tag)
		giveHapticFeedback()
	}
	
	/// Mostra o error para o usuário na tela e limpa a expressão.
	/// - Parameter error: erro que deseja mostrar
	private func displayError(_ error: ErrorCases) {
		screenExpression = error.rawValue
		expression.removeAll()
	}
	
	/// Realiza os updates na view
	private func updateView(with text: String) {
		calculatorView.updateResultLabel(with: text)
	}
	
	/// Dá o feedback háptico para o usuário
	private func giveHapticFeedback() {
		UIImpactFeedbackGenerator(style: .soft).impactOccurred()
	}
	
	/// Realiza a mudança de estado do botão de ponto flutuante
	private func togglePoint() {
		guard let button = calculatorView.viewWithTag(10) as? UIButton else { return }
		if validateInput(input: ".1") {
			isPointActive.toggle()
			if isPointActive {
				button.backgroundColor = .cutePinkSecondary
			} else {
				button.backgroundColor = .cutePinkPrimary
			}
		} else {
			isPointActive = false
			button.backgroundColor = .cutePinkPrimary
		}
	}
	
	/// Coorderna a atualização das expressões de acordo com a tag
	/// - Parameter tag: tag do botão pressionado
	private func updateExpressions(tag: Int) {
		if screenExpression.contains(where: {$0.isLetter}) {
			screenExpression.removeAll()
		}
		
		switch tag {
		case 0...9: // números de 0 a 9
			addNumberToExpression(tag: tag)
		case 10: // botão de ponto decimal
			togglePoint()
		case 20...21: // funções de deletar (limpar tudo ou apagar último)
			deleteOperation(tag)
		case 30...33: // operadores (+, -, *, /)
			addOperatorToExpression(tag)
		case 34: // botão de igual para calcular a expressão
			equalOperation()
		default:
			displayError(.unknownOperation)
		}
	}
	
	/// Adiciona um número a expressão de acordo com o botão pressionado (0-9)
	/// - Parameter tag: tag do botão
	private func addNumberToExpression(tag: Int) {
		if isPointActive {
			expression += ".\(tag)"
			screenExpression += ",\(tag)"
			togglePoint()
		} else {
			expression += "\(tag)"
			screenExpression += "\(tag)"
		}
	}
	
	/// Adiciona um operador a expressão de acordo com o botão pressionado
	/// - Parameter tag: tag do botão
	private func addOperatorToExpression(_ tag: Int) {
		// impede que mais de um operador seja adicionado consecutivamente
		if let lastChar = expression.last, !"+-/*".contains(lastChar) {
			switch tag {
			case 30:
				expression += "/"
				screenExpression += "÷"
			case 31:
				expression += "-"
				screenExpression += "-"
			case 32:
				expression += "+"
				screenExpression += "+"
			case 33:
				expression += "*"
				screenExpression += "×"
			default:
				displayError(.unknownOperation)
			}
		}
	}
	
	/// Valida o input antes de inserir ele de fato na expressão
	/// - Parameter input: caractere desejado a incrementar na expressão
	/// - Returns: booleano se está validado ou não.
	private func validateInput(input: String) -> Bool {
		let expressionToValidate = expression + input
		do {
			if let nsregex = try? NSRegularExpression(pattern: expressionRegexPattern) {
				let range = NSRange(location: 0, length: expressionToValidate.utf16.count)
				let match = nsregex.firstMatch(in: expressionToValidate, options: [], range: range)
				return match != nil
			} else {
				throw NSError(domain: "erro ao validar expressão", code: 1, userInfo: nil)
			}
		} catch {
			return false
		}
	}
	
	/// Realiza as operações de delete de acordo com a operação selecionada
	/// - Parameter tag: tag do botão
	private func deleteOperation(_ tag: Int) {
		switch tag {
		case 20:  // limpar tudo
			expression.removeAll()
			screenExpression.removeAll()
		case 21:  // apagar o último caractere
			if !expression.isEmpty && !screenExpression.isEmpty {
				expression.removeLast()
				screenExpression.removeLast()
			}
		default:
			displayError(.unknownOperation)
		}
	}
	
	/// Formata o resultado dependendo se houve ponto flutuante ou não
	/// - Parameter result: resultado da expressão
	/// - Returns: expressão formatada
	private func formatResult(result: Double) -> String {
		// se o resultado for um número inteiro ele zera as casas decimais
		if result.truncatingRemainder(dividingBy: 1) == 0 {
			return String(format: "%.0f", result)
		} else {
			// retorna com duas casas decimais se for um número com fração
			return String(format: "%.2f", result)
		}
	}
	
	/// Verifica se o resultado é válido antes de formata-lo
	/// - Parameter result: resultado a ser avaliado
	private func handleResult(_ result: Double) {
		if result.isNaN {
			displayError(.invalidNumber)
		} else if result.isInfinite {
			displayError(.infiniteNumber)
		} else {
			expression = formatResult(result: result)
			screenExpression = expression
		}
	}
	
	/// Calcula a expressão e mostra o resultado
	private func equalOperation() {
		if expression.isEmpty { return }
		
		// Remove pontos flutuantes inválidos no final da expressão
		if expression.hasSuffix(".") || "+-*/".contains(expression.last!) {
			expression.removeLast()
			screenExpression.removeLast()
		}
		
		// Valida a expressão antes de tentar calcular
		if !validateInput(input: "") {
			expression.removeAll()
			displayError(.invalidExpression)
			return
		}

		do {
			let expressionOp = NSExpression(format: expression)
			if let result = expressionOp.expressionValue(with: nil, context: nil) as? Double {
				// Atualiza o resultado na tela
				handleResult(result)
			} else {
				throw NSError(domain: "erro ao calcular", code: 1, userInfo: nil)
			}
		} catch {
			expression.removeAll()
			displayError(.invalidExpression)
		}
	}
}
