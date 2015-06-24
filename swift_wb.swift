//
//  swift_wb.swift
//  gusimplewhiteboard
//
//  Created by Rene Hexel on 5/11/2014.
//  Copyright © 2014, 2015 Rene Hexel. All rights reserved.
//
public class Whiteboard {
    let wbd: UnsafeMutablePointer<gu_simple_whiteboard_descriptor>
    public var wb: UnsafeMutablePointer<gu_simple_whiteboard> {
        return wbd.memory.wb
    }
    public static var number_of_messages: Int32 { return GSW_NUM_TYPES_DEFINED }
    public init() {
        wbd = get_local_singleton_whiteboard()
    }
    public func get<T>(msg: wb_types) -> T {
        let msgp = UnsafePointer<T>(gsw_current_message(wb, Int32(msg.rawValue)))
        return msgp.memory
    }

    func post<T>(val: T, msg: wb_types) {
        let msgno = Int32(msg.rawValue)
        let msgp = UnsafeMutablePointer<T>(gsw_next_message(wb, msgno))
        msgp.memory = val
        gsw_increment(wb, msgno)
    }
}

