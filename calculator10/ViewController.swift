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
            display.text = textCurrentlyInDisplay + digit
        } else {
            userIsInTheMiddleOfTyping = true
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
                userIsInTheMiddleOfTyping = digit == "0" ? false : true //deleting insignificant zeros
            }
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
        if let descr = brain.description {
            descriptionLabel.text = descr + brain.suffixOfDescription
        } else {
            descriptionLabel.text = " "
        }
    }

}

