//
//  CalculatorBrain.swift
//  calculator10
//
//  Created by Ruslan on 19.02.17.
//  Copyright © 2017 Ruslan Petrov. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    private var accumulator: Double?
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "cos" : Operation.unaryOperation(cos),
        "sin" : Operation.unaryOperation(sin),
        "±" : Operation.unaryOperation({ -$0 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "-" : Operation.binaryOperation({ $0 - $1 }),
        "=" : Operation.equals
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                accumulatorDescription = String(value)
                if !resultIsPending {
                    description = nil
                }
                
            case .unaryOperation(let function):
                if accumulator != nil {
                    accumulatorDescription = accumulatorDescription != nil ? "\(symbol)(\(accumulatorDescription!))" : "\(symbol)\((accumulator!))"
                    if description == nil {
                        description = accumulatorDescription
                    }
                    if resultIsPending {
                        if description != nil {
                            description!.append(accumulatorDescription!)
                        }
                    } else {
                        description = accumulatorDescription!
                    }
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    description = description != nil ? description! + ("\(symbol)") : ("\(accumulator!)\(symbol)")
                    accumulator = nil
                    accumulatorDescription = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            if accumulatorDescription != nil && String(accumulator!) == accumulatorDescription! {
                description!.append("\(accumulatorDescription!)")
            }
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private var resultIsPending: Bool {
        get {
            return (pendingBinaryOperation != nil) ? true : false
        }
    }
    
    public var suffixOfDescription: String {
        return resultIsPending ? "…" : "="
    }
    
    public var description: String?
    private var accumulatorDescription: String?
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand (_ operand: Double) {
        accumulator = operand
        accumulatorDescription = String(accumulator!)
        if !resultIsPending {
            description = nil
        }
    }
    public var result: Double?  {
        get {
            return accumulator
        }
    }
}
