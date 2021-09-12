//
//  BankAccount.swift
//  BankAccount
//
//  Created by machao13 on 2021/8/14.
//

import Foundation

actor BankAccount {
    
    let accountNumber: Int
    
    let accountName: String
    
    var balance: Double
    
    init(_ accountNumber: Int, _ balance: Double, _ accountName: String) {
        self.accountNumber = accountNumber
        self.balance = balance
        self.accountName = accountName
    }
    
    enum BankError: Error {
        case insufficientFunds
    }
    
    func deposite(amount: Double) async {
        assert(amount > 0)
        balance += amount
    }
    
    func transfer(amount: Double, to other: BankAccount) async throws {
        
        if amount > balance {
            throw BankError.insufficientFunds
        }
        
        let t = TimeInterval.random(in: 0.25 ... 2.0)
        Thread.sleep(forTimeInterval: t)
        
        print("\(accountName) Transferring to \(other.accountName) \(amount) from \(accountNumber) to \(other.accountNumber) the thread is \(Thread.current)")
        
        balance = balance - amount
        
        await other.deposite(amount: amount)
        
    }
    
}
