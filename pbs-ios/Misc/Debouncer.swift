//
//  Debouncer.swift
//  pbs-ios
//
//  Created by Jesper Dinger on 28/05/2025.
//

import Foundation

class Debouncer {
    private var workItem: DispatchWorkItem?
    private let queue: DispatchQueue
    private let delay: TimeInterval

    init(delay: TimeInterval) {
        self.delay = delay
        self.queue = DispatchQueue(label: "dev.gwep.pbs")
    }

    func run(action: @escaping () -> Void) {
        // Cancel previous work item if it exists
        workItem?.cancel()

        // Create a new work item
        workItem = DispatchWorkItem(block: action)

        // Execute after the delay
        if let workItem = workItem {
            queue.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}
