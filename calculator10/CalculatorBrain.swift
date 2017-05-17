//
//  CalculatorBrain.swift
//  calculator10
//
//  Created by Ruslan on 19.02.17.
//  Copyright © 2017 Ruslan Petrov. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var descriptionAccumulator = " "
    
    private enum operationHistoryItem {
        case operand(Double)
        case operation(String)
        case variable(String)
    }
    
    private var operationHistory = [operationHistoryItem]()
    
    private enum Operation {
        case constant(Double)
        case nullaryOperation(() -> Double, String)
        case unaryOperation((Double) -> Double, ((String) -> String)?, ((Double) -> String?)?)
        case binaryOperation((Double, Double) -> Double, ((String, String) -> String)?, ((Double, Double) -> String?)?)
        case equals
        
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "rand" : Operation.nullaryOperation({ Double(arc4random()) / Double(UINT32_MAX)}, "rand(0..1)"),
        "√" : Operation.unaryOperation(sqrt, nil, { $0 < 0 ? "√ of negative number" : nil } ),
        "sin" : Operation.unaryOperation(sin, nil, nil),
        "cos" : Operation.unaryOperation(cos, nil, nil),
        "tan": Operation.unaryOperation(tan,nil, nil),
        "ln" : Operation.unaryOperation(log, nil, { $0 <= 0 ? "ln of non-positive number" : nil } ),
        "±" : Operation.unaryOperation({ -$0 }, nil, nil),
        "x⁻¹" : Operation.unaryOperation({1.0/$0}, {"(" + $0 + ")⁻¹"}, { $0 == 0 ? "Dividing by 0" : nil } ),
        "х²" : Operation.unaryOperation({1.0/$0}, {"(" + $0 + ")²"}, nil),
        "×" : Operation.binaryOperation(*, nil, nil),
        "÷" : Operation.binaryOperation(/, nil, { $1 == 0 ? "Dividing by 0" : nil } ),
        "+" : Operation.binaryOperation(+, nil, nil),
        "-" : Operation.binaryOperation(-, nil, nil),
        "xʸ" : Operation.binaryOperation(pow, { $0 + "^" + $1 }, nil),
        "=" : Operation.equals
    ]
    
    mutating func clear() {
        operationHistory.removeAll()
    }
    
    mutating func undo() {
        if !operationHistory.isEmpty {
            operationHistory = Array(operationHistory.dropLast())
        }
    }
    
    struct PendingBinaryOperation {     //mevorizes first operand and operation while binary operation is pending (
        let function: (Double, Double) -> Double
        let firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
        var validator: ((Double, Double) -> String?)?
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        func performDescription(with secondOperand: String) -> String {
            return descriptionFunction(descriptionOperand, secondOperand)
        }
        func validate(with secondOperand: Double) -> String? {
            guard let validator = validator else { return nil }
            return validator(firstOperand, secondOperand)
        }
        
    }
    
    mutating func setOperand (_ operand: Double) {  operationHistory.append(operationHistoryItem.operand(operand))  }
    
    mutating func setOperand (named variable: String) { operationHistory.append(operationHistoryItem.variable(variable))    }
    
    mutating func performOperation(_ symbol: String) {  operationHistory.append(operationHistoryItem.operation(symbol))  }
    
    func evaluate(using variables: Dictionary<String, Double>? = nil) -> (result: Double?, isPending: Bool, description: String, error: String?) {
        
        var cache: (accumulator: Double?, descriptionAccumulator: String?)
        var error: String?
        
        var pendingBinaryOperation: PendingBinaryOperation?
        
        var description: String? {
            if pendingBinaryOperation == nil {
                return cache.descriptionAccumulator
            } else {
                return pendingBinaryOperation!.descriptionFunction(pendingBinaryOperation!.descriptionOperand,
                                                                   cache.descriptionAccumulator ?? "")

            }
        }
        
        var result: Double? { return cache.accumulator }
        
        var resultIsPending: Bool { return pendingBinaryOperation != nil }
        
        // MARK: Nested functions evaluate
        
        func setOperand(_ operand: Double) {
            cache.accumulator = operand
            if let value = cache.accumulator {
                cache.descriptionAccumulator = formatter.string(from: NSNumber(value: value)) ?? ""
            }
        }
        
        func setOperand(named variable: String) {
            cache.accumulator = variables?[variable] ?? 0
            cache.descriptionAccumulator = variable
        }
        
        func performOperation(_ symbol: String) {
            if let operation = operations[symbol] {
                switch operation {
                case .nullaryOperation(let function, let descriptionValue):
                    cache = (function(), descriptionValue)
                case .constant(let value):
                    cache = (value, symbol)
                case .unaryOperation(let function, var descriptionFunction, let validator):
                    guard cache.accumulator != nil else { return }
                    error = validator?(cache.accumulator!)
                    cache.accumulator = function(cache.accumulator!)
                    if descriptionFunction == nil {
                        descriptionFunction = { symbol + "(" + $0 + ")" }
                    }
                    cache.descriptionAccumulator = descriptionFunction!(cache.descriptionAccumulator!)
                case .binaryOperation(let function, var descriptionFunction, let validator):
                    performPendingBinaryOperation()
                    guard cache.accumulator != nil else { return }
                    if descriptionFunction == nil {
                        descriptionFunction = { $0 + symbol + $1 }
                    }
                    pendingBinaryOperation = PendingBinaryOperation(function: function,
                                                                    firstOperand: cache.accumulator!,
                                                                    descriptionFunction: descriptionFunction!,
                                                                    descriptionOperand: cache.descriptionAccumulator!,
                                                                    validator: validator)
                    cache = (nil, nil)
                case .equals:
                    performPendingBinaryOperation()
                }
            }
        }
        
        func performPendingBinaryOperation () {
            guard pendingBinaryOperation != nil && cache.accumulator != nil else { return }
            error = pendingBinaryOperation!.validate(with: cache.accumulator!)
            cache.accumulator = pendingBinaryOperation!.perform(with: cache.accumulator!)
            cache.descriptionAccumulator = pendingBinaryOperation?.performDescription(with: cache.descriptionAccumulator!)
            pendingBinaryOperation = nil
        }
        
        
        // MARK: Body evaluate
        
        guard !operationHistory.isEmpty else { return (nil, false, " ", nil)}
        for item in operationHistory {
            switch item {
            case .operand(let operand):
                setOperand(operand)
            case .variable(let operand):
                setOperand(named: operand)
            case .operation(let symbol):
                performOperation(symbol)
            }
        }
        return (result, resultIsPending, description ?? "", error)
        
    }

    @available(iOS, deprecated, message: "No longer needed")
    public var description: String {
        return evaluate().description
    }
    
    @available(iOS, deprecated, message: "No longer needed")
    public var result: Double?  {
        return evaluate().result
    }
    
    @available(iOS, deprecated, message: "No longer needed")
    public var resultIsPending: Bool {
        return evaluate().isPending
    }
    
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.notANumberSymbol = "Error"
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        return formatter
    } ()
}
