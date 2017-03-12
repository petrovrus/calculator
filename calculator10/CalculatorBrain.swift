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
    private var descriptionAccumulator = " "
    
    public var description: String {
        if pendingBinaryOperation == nil {
            return descriptionAccumulator
        } else {
            return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand,
                                                               pendingBinaryOperation!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : " ")
        }
    }
    
    
    private enum Operation {
        case constant(Double)
        case nullaryOperation(() -> Double, String)
        case unaryOperation((Double) -> Double, ((String) -> String)?)
        case binaryOperation((Double, Double) -> Double, ((String, String) -> String)?)
        case equals
        
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "rand" : Operation.nullaryOperation({ Double(arc4random()) / Double(UINT32_MAX)}, "rand(0..1)"),
        "√" : Operation.unaryOperation(sqrt, nil),
        "sin" : Operation.unaryOperation(sin, nil),
        "cos" : Operation.unaryOperation(cos, nil),
        "tan": Operation.unaryOperation(tan,nil),
        "ln" : Operation.unaryOperation(log, nil),
        "±" : Operation.unaryOperation({ -$0 }, nil),
        "x⁻¹" : Operation.unaryOperation({1.0/$0}, {"(" + $0 + ")⁻¹"}),
        "×" : Operation.binaryOperation(*, nil),
        "÷" : Operation.binaryOperation(/, nil),
        "+" : Operation.binaryOperation(+, nil),
        "-" : Operation.binaryOperation(-, nil),
        "xʸ" : Operation.binaryOperation(pow, { $0 + "^" + $1 }),
        "=" : Operation.equals
    ]
    
    mutating func superClear() {
        accumulator = nil
        pendingBinaryOperation = nil
        descriptionAccumulator = " "
    }
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .unaryOperation(let function, var descriptionFunction):
                if accumulator != nil {
                    accumulator = function(accumulator!)
                    if descriptionFunction == nil {
                        descriptionFunction = {symbol + "(" + $0 + ")"}
                    }
                    descriptionAccumulator = descriptionFunction!(descriptionAccumulator)
                }
            case .binaryOperation(let function, var descriptionFunction):
                performPendingBinaryOperation()
                if accumulator != nil {
                    if descriptionFunction == nil {
                        descriptionFunction = {$0 + symbol + $1}
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, descriptionFunction: descriptionFunction!, descriptionOperand: descriptionAccumulator)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            descriptionAccumulator = pendingBinaryOperation!.performDescription(with: descriptionAccumulator)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    public var resultIsPending: Bool {
        get {
            return (pendingBinaryOperation != nil) ? true : false
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        func performDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
    }
    
    mutating func setOperand (_ operand: Double) {
        accumulator = operand
        if let value = accumulator {
            descriptionAccumulator = String(value)
        }
    }
    
    public var result: Double?  {
        get {
            return accumulator
        }
    }
}
