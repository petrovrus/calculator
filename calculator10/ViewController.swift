//
//  ViewController.swift
//  calculator10
//
//  Created by Ruslan on 16.02.17.
//  Copyright © 2017 Ruslan Petrov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    @IBOutlet weak var displayM: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if (digit != ".") || !(textCurrentlyInDisplay.contains(".")) {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    @IBAction func setM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = "M"
        
        variableValues[symbol] = displayValue
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func pushM(_ sender: UIButton) {
        let symbol = "M"
        brain.setOperand(named: symbol)
        displayResult = brain.evaluate(using: variableValues)
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain.clear()
        variableValues.removeAll()
        displayResult = brain.evaluate()
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            guard !display.text!.isEmpty else { return }
            display.text = String(display.text!.characters.dropLast())
            if display.text!.isEmpty {
                displayValue = 0
                userIsInTheMiddleOfTyping = false
                displayResult = brain.evaluate(using: variableValues)
            }
        } else {
            brain.undo()
            displayResult = brain.evaluate(using: variableValues)
        }
    }

    
    @IBAction func removeLastDigit(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping && !display.text!.isEmpty {
            display.text = String(display.text!.characters.dropLast())
        }
        if display.text!.isEmpty {
            displayValue = 0.0
            userIsInTheMiddleOfTyping = false
        }
    }
    
    private var displayValue: Double? {
        get {
            return Double(display.text!) ?? nil
        }
        set {
            display.text = newValue != nil ? String(newValue!) : "0"
        }
    }
    
    private var displayResult: (result: Double?, isPending: Bool, description: String, error: String?) = (nil, false, " ", nil) {
        didSet {
            switch displayResult {
            case (nil, _, " ", nil):
                displayValue = 0
            case (let result, _, _, nil):
                displayValue = result
            case (_, _, _, let error):
                display.text = error!
            }
            history.text = displayResult.description != " " ? displayResult.description + (displayResult.isPending ? " …" : " =") : " "
            displayM.text = brain.formatter.string(from: NSNumber(value: variableValues["M"] ?? 0))
            
        }
    }
    
    private var brain = CalculatorBrain()
    private var variableValues = [String: Double]()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if let value = displayValue {
                brain.setOperand(value)
            }
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayResult = brain.evaluate(using: variableValues)
    }
    
    
}

