//
//  Calculator - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class CalculatorViewController: UIViewController {
    static let zero: String = "0"
    static let empty: String = ""
    static let negativeSign: Character = "-"
    static let nanResult: String = "NaN"
    
    private var formulaNotYetCalculated: String = empty
    private var calculator: Formula = Formula()
    private var formerOperator: String = empty
    private var inputtingOperand: String = zero {
        didSet {
            numberLabel.text = inputtingOperand
            do {
                try inputIsWithinRange(inputtingOperand)
            } catch {
                setUpDefaultStatus()
            }
        }
    }
    private var inputtingOperator: String = empty {
        didSet {
            operatorLabel.text = inputtingOperator
        }
    }
    
    private enum CalculatorStatus {
        case initStatus, zeroStatus, nonZeroStatus
    }
    
    private var calculatorStatus: CalculatorStatus = .zeroStatus
    private let numberFormatter = NumberFormatter()
    
    @IBOutlet private weak var operandZeroButton: OperandButton!
    @IBOutlet private weak var operandCoupleZeroButton: OperandButton!
    @IBOutlet private weak var operandOneButton: OperandButton!
    @IBOutlet private weak var operandTwoButton: OperandButton!
    @IBOutlet private weak var operandThreeButton: OperandButton!
    @IBOutlet private weak var operandFourButton: OperandButton!
    @IBOutlet private weak var operandFiveButton: OperandButton!
    @IBOutlet private weak var operandSixButton: OperandButton!
    @IBOutlet private weak var operandSevenButton: OperandButton!
    @IBOutlet private weak var operandEightButton: OperandButton!
    @IBOutlet private weak var operandNineButton: OperandButton!
    @IBOutlet private weak var operandDotButton: OperandButton!
    
    @IBOutlet private weak var operatorAddButton: OperatorButton!
    @IBOutlet private weak var operatorSubtractButton: OperatorButton!
    @IBOutlet private weak var operatorMultiplyButton: OperatorButton!
    @IBOutlet private weak var operatorDivideButton: OperatorButton!
    
    @IBOutlet private weak var funcAllClearButton: FunctionalButton!
    @IBOutlet private weak var funcClearEntryButton: FunctionalButton!
    @IBOutlet private weak var funcChangeSignButton: FunctionalButton!
    @IBOutlet private weak var funcExecuteButton: FunctionalButton!
    
    @IBOutlet private weak var operatorLabel: UILabel!
    @IBOutlet private weak var numberLabel: UILabel!
    
    @IBOutlet private weak var historyScrollView: UIScrollView!
    @IBOutlet private weak var historyStackView: UIStackView!
    
    private func inputIsWithinRange(_ inputtingOperand: String) throws {
        guard inputtingOperand.count <= 20 else {
            throw CalculatorError.outOfInputRange
        }
    }
    
    private func setUpDefaultStatus() {
        clearFormula()
        clearInputtingOperand()
        clearInputtingOperator()
        setStatusInit()
        clearFormerInputOperator()
    }
    
    private func clearFormula() {
        formulaNotYetCalculated = CalculatorViewController.empty
    }
    
    private func clearInputtingOperand() {
        inputtingOperand = CalculatorViewController.zero
    }
    
    private func clearInputtingOperator() {
        inputtingOperator = CalculatorViewController.empty
    }
    
    private func setStatusInit() {
        calculatorStatus = .initStatus
    }
    
    private func clearFormerInputOperator() {
        formerOperator = CalculatorViewController.empty
    }
    
    private func setStatusZero() {
        clearInputtingOperand()
        calculatorStatus = .zeroStatus
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNumberFormat()
        setUpOperandButtonValue()
        setUpOpertorButtonValue()
        setUpHistoryStackView()
        setUpDefaultStatus()
    }
    
    private func setUpNumberFormat() {
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumSignificantDigits = 20
        numberFormatter.roundingMode = .halfUp
    }
    
    private func setUpOperandButtonValue() {
        operandZeroButton.value = "0"
        operandCoupleZeroButton.value = "00"
        operandOneButton.value = "1"
        operandTwoButton.value = "2"
        operandThreeButton.value = "3"
        operandFourButton.value = "4"
        operandFiveButton.value = "5"
        operandSixButton.value = "6"
        operandSevenButton.value = "7"
        operandEightButton.value = "8"
        operandNineButton.value = "9"
        operandDotButton.value = "."
    }

    private func setUpOpertorButtonValue() {
        operatorAddButton.value = " + "
        operatorSubtractButton.value = " - "
        operatorMultiplyButton.value = " × "
        operatorDivideButton.value = " ÷ "
    }
    
    private func setUpHistoryStackView() {
        historyStackView.spacing = 8
        historyStackView.distribution = .fillEqually
        clearHistoryStackView()
    }
    
    private func clearHistoryStackView() {
        for historyView in historyStackView.arrangedSubviews {
            historyView.removeFromSuperview()
            historyStackView.removeArrangedSubview(historyView)
        }
    }
    
    @IBAction private func operandButtonAction(_ sender: OperandButton) {
        generateOperandNumber(sender)
        addOperatorToFormulaIfExists()
    }
    
    private func generateOperandNumber(_ sender: OperandButton) {
        guard let input = sender.value else { return }
        if calculatorStatus != .nonZeroStatus || inputtingOperand == CalculatorViewController.zero {
            if sender == operandZeroButton || sender == operandCoupleZeroButton {
                inputtingOperand = CalculatorViewController.zero
            } else if sender == operandDotButton {
                inputtingOperand += input
            } else {
                inputtingOperand = input
            }
            calculatorStatus = .nonZeroStatus
        } else {
            inputtingOperand += input
        }
    }
    
    private func addOperatorToFormulaIfExists() {
        if !inputtingOperator.isEmpty {
            let lastInputtedOperator = operatorLabel.text
            formulaNotYetCalculated += inputtingOperator
            clearInputtingOperator()
            operatorLabel.text = lastInputtedOperator
            formerOperator = lastInputtedOperator ?? CalculatorViewController.empty
        }
    }
    
    @IBAction private func operatorButtonAction(_ sender: OperatorButton) {
        guard calculatorStatus != .initStatus else { return }
        guard let input = sender.value else { return }
        inputtingOperator = input
        guard calculatorStatus == .nonZeroStatus else { return }
        
        if historyStackView.arrangedSubviews.count < 1 {
            insertHistoryInStackView(inputtingOperand)
        } else {
            insertHistoryInStackView(formerOperator + inputtingOperand)
        }
        addOperandToFormula()
    }
    
    private func addOperandToFormula() {
        formulaNotYetCalculated += inputtingOperand
        setStatusZero()
        formerOperator = inputtingOperator
    }
    
    @IBAction private func allClearAction(_ sender: FunctionalButton) {
        setUpDefaultStatus()
        clearHistoryStackView()
    }
    
    @IBAction private func clearEntryAction(_ sender: FunctionalButton) {
        setStatusZero()
    }
    
    @IBAction private func changeSignAction(_ sender: FunctionalButton) {
        if inputtingOperand == CalculatorViewController.zero {
            return
        } else if inputtingOperand.first == CalculatorViewController.negativeSign {
            inputtingOperand.remove(at: inputtingOperand.startIndex)
        } else {
            inputtingOperand.insert(CalculatorViewController.negativeSign, at: inputtingOperand.startIndex)
        }
    }
    
    @IBAction private func executeCalculatingAction(_ sender: FunctionalButton) {
        guard !formulaNotYetCalculated.isEmpty, calculatorStatus == .nonZeroStatus else  { return }
        
        insertHistoryInStackView(formerOperator + inputtingOperand)
        formulaNotYetCalculated += inputtingOperand
        clearInputtingOperand()
        
        var parser = ExpressionParser.parse(from: formulaNotYetCalculated)
        setUpDefaultStatus()
        
        guard let result = try? parser.result() as Double else { return }
        configureCalculateResultLabel(result)
    }
    
    private func configureCalculateResultLabel(_ result: Double) {
        if result.isNaN {
            numberLabel.text = CalculatorViewController.nanResult
        } else if cannotUseNumberFormatter(result) {
            let integerLength = String(result).components(separatedBy: ".")[0].count
            numberLabel.text = String(format: "%.\(String(20 - integerLength))f", result)
        } else {
            guard let numberFormattedResult = numberFormatter.string(for: result) else { return }
            numberLabel.text = numberFormattedResult
        }
    }
    
    private func cannotUseNumberFormatter(_ result: Double) -> Bool {
        let componentsByDecimalSeperator = String(result).components(separatedBy: ".")
        let integerLength = componentsByDecimalSeperator[0].count
        let decimalLength = componentsByDecimalSeperator[1].count
           
        return decimalLength >= 16 && integerLength + decimalLength < 20
    }
    
    private func insertHistoryInStackView(_ inputted: String) {
        let stackView = historyStackView(inputted)
        historyStackView.addArrangedSubview(stackView)
        let offsetY = historyScrollView.contentSize.height - historyScrollView.bounds.height
        
        if(offsetY > 0) {
            historyScrollView.setContentOffset(CGPoint(x: 0, y: (historyScrollView.contentSize.height - historyScrollView.bounds.height + 30)), animated: true)
        }
    }
    
    private func historyStackView(_ inputted: String) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let formulaHistory = UILabel()
        formulaHistory.text = inputted
        formulaHistory.textColor = .white
        formulaHistory.textAlignment = .right
        
        stackView.addArrangedSubview(formulaHistory)
        
        return stackView
    }
}

