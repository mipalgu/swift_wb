//
//  Whiteboard.swift
//  gusimplewhiteboard
//
//  Created by Rene Hexel on 5/11/2014.
//  Copyright © 2014, 2015 Rene Hexel. All rights reserved.
//

import CGUSimpleWhiteboard

//swiftlint:disable identifier_name

/// Public protocol for blackboard-like functionality
public protocol Blackboard {
    /// required constructor for a default whiteboard
    init()

    /// return the number of known message types
    static var number_of_messages: Int32 { get }

    /// get a message of a given type
    func get<T>(_ msg: wb_types) -> T

    /// post a message of a given type to a given `wb_types` slot
    func post<T>(_ val: T, msg: wb_types)
}

/// Swift convenience wrapper around gusimplewhiteboard
public struct Whiteboard: Blackboard {
    /// pointer to the underlying C whiteboard implementation
    let wbd: UnsafeMutablePointer<gu_simple_whiteboard_descriptor>

    /// return ta pointer to the underlying C whiteboard infrastructure
    public var wb: UnsafeMutablePointer<gu_simple_whiteboard> {
        return wbd.pointee.wb
    }

    /// convenience class variable denoting the number of defined wb types
    public static var number_of_messages: Int32 { return GSW_NUM_TYPES_DEFINED }

    /// constructor for the default, singleton whiteboard
    public init() {
        self.wbd = get_local_singleton_whiteboard()
    }

    public init(wbd: UnsafeMutablePointer<gu_simple_whiteboard_descriptor>) {
        self.wbd = wbd
    }

    /// get message template function
    public func get<T>(_ msg: wb_types) -> T {
        return gsw_current_message(wb, Int32(msg.rawValue)).withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
    }

    // get message converting to a swift wrapper.
    public func get<T>(_ msg: wb_types) -> T where T: WhiteboardTypeConvertible {
        let currentMessage: T.WhiteboardType = self.get(msg)
        return T(currentMessage)
    } 

    /// post message template function
    public func post<T>(_ val: T, msg: wb_types) {
        let msgno = Int32(msg.rawValue)
        gsw_next_message(wb, msgno).withMemoryRebound(to: T.self, capacity: 1) { $0.pointee = val }
        gsw_increment(wb, msgno)
    }

    // post message from swift wrapper template function.
    public func post<T>(_ val: T, msg: wb_types) where T: WhiteboardTypeConvertible {
        self.post(val.rawValue, msg: msg)
    }
}
