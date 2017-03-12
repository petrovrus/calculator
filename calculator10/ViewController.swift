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
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
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
    
    @IBAction func clearAll(_ sender: UIButton) {
        brain.superClear()
        displayValue = 0
        descriptionLabel.text = " "
        userIsInTheMiddleOfTyping = false
    }
    
    @IBAction func clearNumber(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            displayValue = 0
            userIsInTheMiddleOfTyping = false
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
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping, let value = displayValue {
            brain.setOperand(value)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        descriptionLabel.text = brain.description + (brain.resultIsPending ? "…" : "=")
    }
    
}

