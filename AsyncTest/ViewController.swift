//
//  ViewController.swift
//  AsyncTest
//
//  Created by machao13 on 2021/8/13.
//

import UIKit
import HealthKit

protocol AsyncProtocol {
    
    func asyncProtocolMethod() async -> Bool
    
    var asyncVal: String { get async }
    
}

enum FileError: Error {
    case missing, unreadable
}

struct BundleFile {
    
    var fileName: String
    
    var content: String {
        get async throws {
            
            guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else {
                throw FileError.missing
            }
            
            do {
                return try String(contentsOf: url)
            } catch {
                throw FileError.unreadable
            }
            
        }
    }
    
}

struct Counter: AsyncSequence {
    typealias Element = Int
    
    let howHigh: Int
    
    struct AsyncIterator: AsyncIteratorProtocol {
        let howHigh: Int
        var current = 1
        
        mutating func next() async throws -> Int? {
            guard current <= howHigh else {
                return nil
            }
            
            let result = current
            current += 1
            return result
        }
        
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(howHigh: howHigh)
    }
    
}

class ViewController: UIViewController {

    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var groupTaskBtn: UIButton!
    @IBOutlet weak var bankAccountBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task(priority: .high) {
            
            await doSomeThing()
            
            syncDoSomeThing()

        }

        doSomeThing()
        
    }
    
    private func asyncTestOne() async {
        print("the async thread is \(Thread.current)")
    }

    @IBAction func btnClicked(_ sender: Any) {
        
        Task(priority: .high) {
            await load()
            print("the async btnClicked thread is \(Thread.current)")
        }
        
    }
    
//    @IBAction func syncBtnClicked(_ sender: Any) {
//
//        Task(priority: .high) {
//            await syncLoad()
//            print("the sync btnClicked thread is \(Thread.current)")
//        }
//
//    }
    
    @IBAction func groupTaskBtnClicked(_ sender: Any) {
        
//        Task(priority: .high) {
//            await groupTaskRun()
//        }
        Task(priority: .high) {
            async let taskOne = doIt()
            async let taskTwo = doIt()
            async let taskThree = doIt()

            let result = await [taskOne, taskTwo, taskThree]
            print("the thread is \(Thread.current), result is \(result)")
        }

//        Task {
//            async let (l, r) = await (left(), right())
//
//            print("the l is \(await l)")
//            print("the r is \(await r)")
//        }
        
    }
    
    private func groupTaskRun() async {
        
        await withTaskGroup(of: String.self, body: { group in
            
            group.addTask {
                await self.doIt()
            }
            group.addTask {
                await self.doIt()
            }
            
            group.addTask {
                return await self.doIt()
            }
            
            var result: [String] = []
            for await step in group {
                result.append(step)
            }
            
            print("the thread is \(Thread.current), result is \(result)")
        })
        
    }
    
    @IBAction func bankAccountBtnClicked(_ sender: Any) {
        
        let a: BankAccount = BankAccount(1, 1000000, "Andy")
        let b: BankAccount = BankAccount(1, 1000000, "Jack")
        
        for _ in 0...20 {
            Task {
                Task(priority: .userInitiated) {
                    let aAmount = Int.random(in: 1...100)
                    try await a.transfer(amount: Double(aAmount), to: b)
                }
                Task(priority: .userInitiated) {
                    let bAmount = Int.random(in: 1...100)
                    try await b.transfer(amount: Double(bAmount), to: a)
                }
            }
        }
        
    }
    
    @IBAction func asyncSequeueBtnClicked(_ sender: Any) {
            
        Task {
            let counter: Counter = Counter(howHigh: 10)
            
            for try await i in counter {
                print("the val is \(i), thread is \(Thread.current)")
            }
        }
    }
    
    
    func doIt() async -> String {
        let t = TimeInterval.random(in: 0.25 ... 2.0)
        Thread.sleep(forTimeInterval: t)
        print("the current thread is \(Thread.current)")
        return String("\(Double.random(in: 0...1000))")
    }
    
    private func left() async -> String {
        print("the left thread is \(Thread.current)")
        return "l"
    }
    
    private func right() async -> String {
        print("the right thread is \(Thread.current)")
        return "r"
    }
    
    private func groupAsyncTaskOne() async -> Bool {
        Thread.sleep(forTimeInterval: 2)
        print("groupAsyncTaskOne, thread is \(Thread.current)")
        return true
    }
    
    private func groupAsyncTaskTwo() async -> Bool {
        Thread.sleep(forTimeInterval: 5)
        print("groupAsyncTaskTwo, thread is \(Thread.current)")
        return false
    }
    
    private func groupAsyncTaskThree() async -> Bool {
        Thread.sleep(forTimeInterval: 3)
        print("groupAsyncTaskThree, thread is \(Thread.current)")
        return true
    }
    
    private func groupTaskValue(_ values: [Bool]) -> [Bool] {
        print("groupAsyncTaskValue, thread is \(Thread.current)")
        return values
    }
    
    private func load() async {
        
        let list: [String] = await requestDataList()

        print("the load Thread is \(Thread.current), list is \(list)")
        
    }
    
    private func syncLoad() async {
        
        let list: [String] = await requestDataList()

        print("the load Thread is \(Thread.current), list is \(list)")
        
    }
    
    private func requestDataList() async -> [String] {
        
        var list: [String] = []
        for i in 1..<10 {
            Thread.sleep(forTimeInterval: 0.2)
            list.append("\(i)")
        }
        print("the list thread is \(Thread.current)")
        return list
    }
    
    private func doSomeThing() {
        print("the sync do something, thread is \(Thread.current)")
    }
    
    private func doSomeThing() async {
        Thread.sleep(forTimeInterval: 5.0)
        print("the async do something, thread is \(Thread.current)")
    }
    
    private func syncDoSomeThing() {
//        Thread.sleep(forTimeInterval: 3.0)
        print("the syncDoSomeThing, thread is \(Thread.current)")
    }
    
}
