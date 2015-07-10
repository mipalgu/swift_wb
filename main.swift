//
//  main.swift
//  wb_fun
//
//  Created by Rene Hexel on 5/11/2014.
//  Copyright © 2014, 2015 Rene Hexel. All rights reserved.
//
print("Got \(Whiteboard.number_of_messages) whiteboard types defined")

let wb = Whiteboard()

let p = wb_point2d(x: 12, y: 34)

wb.post(p, msg: kXEyesPos_v)
let q: wb_point2d = wb.get(kXEyesPos_v)

print("Posted    point at (\(p.x), \(p.y))")
print("Received  point at (\(q.x), \(q.y))")

extension Whiteboard {
    func get_point2d(msgno: Int32 = Int32(kXEyesPos_v.rawValue)) -> wb_point2d {
        let msgp = UnsafePointer<wb_point2d>(gsw_current_message(wb, msgno))
        return msgp.memory
    }

    func set_point2d(p: wb_point2d, msgno: Int32 = Int32(kXEyesPos_v.rawValue)) {
        let msgp = UnsafeMutablePointer<wb_point2d>(gsw_next_message(wb, msgno))
        msgp.memory = p
        gsw_increment(wb, msgno)
    }
}

wb.set_point2d(p)           // post wb message
let r = wb.get_point2d()    // and get it back

print("Extension point at (\(r.x), \(r.y))")
