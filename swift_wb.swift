//
//  swift_wb.swift
//  gusimplewhiteboard
//
//  Created by Rene Hexel on 5/11/2014.
//  Copyright © 2014, 2015 Rene Hexel. All rights reserved.
//
/// Public protocol for blackboard-like functionality
public protocol Blackboard {
    /// required constructor for a default whiteboard
    init()

    /// return the number of known message types
    static var number_of_messages: Int32 { get }

    /// get a message of a given type
    func get<T>(msg: wb_types) -> T

    /// post a message of a given type to a given `wb_types` slot
    func post<T>(val: T, msg: wb_types)
}


/// Swift convenience wrapper around gusimplewhiteboard
public struct Whiteboard: Blackboard {
    /// pointer to the underlying C whiteboard implementation
    let wbd: UnsafeMutablePointer<gu_simple_whiteboard_descriptor>

    /// return ta pointer to the underlying C whiteboard infrastructure
    public var wb: UnsafeMutablePointer<gu_simple_whiteboard> {
        return wbd.memory.wb
    }

    /// convenience class variable denoting the number of defined wb types
    public static var number_of_messages: Int32 { return GSW_NUM_TYPES_DEFINED }

    /// constructor for the default, singleton whiteboard
    public init() { wbd = get_local_singleton_whiteboard() }

    /// get message template function
    public func get<T>(msg: wb_types) -> T {
        let msgp = UnsafePointer<T>(gsw_current_message(wb, Int32(msg.rawValue)))
        return msgp.memory
    }

    /// post message template function
    public func post<T>(val: T, msg: wb_types) {
        let msgno = Int32(msg.rawValue)
        let msgp = UnsafeMutablePointer<T>(gsw_next_message(wb, msgno))
        msgp.memory = val
        gsw_increment(wb, msgno)
    }
}

