/*
 * GenericWhiteboard.swift 
 * FSM 
 *
 * Created by Callum McColl on 19/03/2016.
 * Copyright © 2016 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import CGUSimpleWhiteboard

/**
 *  Provides a wrapper around `Whiteboard` that only works with a certain
 *  message.
 */
public class GenericWhiteboard<T: ExternalVariables> {
    
    /**
     *  The type of the message.
     */
    public typealias Message = T

    private let atomic: Bool
    private let msgType: wb_types
    private let shouldNotifySubscribers: Bool
    private var procuredCount: UInt8 = 0
    private let wb: Whiteboard

    /**
     *  The current index position of message.
     */
    public var currentIndex: UInt8 {
        let _ = self.procure()
        let index: UInt8 = self.indexes[self.msgTypeOffset]
        let _ = self.vacate()
        return index
    }

    /**
     *  The latest message.
     */
    public var currentMessage: Message {
        get {
            return self.get()
        } set {
            self.post(val: newValue)
        }
    }

    /**
     *  The current event count for the message.
     */
    public var eventCount: UInt16 {
        let _ = self.procure()
        let e: UInt16 = self.eventCounters[self.msgTypeOffset]
        let _ = self.vacate()
        return e
    }

    /**
     *  Event counters for all messages types.
     */
    public var eventCounters: Array<UInt16> {
        return Array(UnsafeBufferPointer(
            start: &self.gsw.pointee.event_counters.0,
            count: self.totalMessageTypes
        ))
    }

    /**
     *  The current `GU_SIMPLE_WHITEBOARD_GENERATIONS`.
     *
     *  This value represents the maximum number of messages that can be stored
     *  for a given message type at any given time.
     */
    public var generations: Int {
        return Int(GU_SIMPLE_WHITEBOARD_GENERATIONS)
    }

    /**
     *  An UnsafeMutablePointer to the `gu_simple_whiteboard`.
     */
    public var gsw: UnsafeMutablePointer<gu_simple_whiteboard> {
        return self.wb.wbd.pointee.wb
    }

    /**
     *  Indexes for all message types.
     */
    public var indexes: Array<UInt8> {
        return Array(UnsafeBufferPointer(
            start: &self.gsw.pointee.indexes.0,
            count: self.totalMessageTypes
        ))
    }

    /**
     *  All messages currently stored in the whiteboard.
     *
     *  - SeeAlso: `ConvertibleCArray`
     */
    public var messages: Array<Message> {
        let first = &self.gsw.pointee.messages.0
        let start = first.withMemoryRebound(to: Message.self, capacity: 1) { $0 }
        let count = self.generations
        return Array(UnsafeBufferPointer(start: start, count: count))
    }

    /**
     *  All messages for the current message type, but they are ordered so that
     *  the latest is first.
     */
    public var orderedMessages: [Message] {
        let _ = self.procure()
        let m: [Message] = self.messages
        var i: Int = Int(self.currentIndex)
        let generations: Int = self.generations
        var arr: [Message] = []
        arr.reserveCapacity(m.count)
        for _ in 0 ..< generations {
            arr.append(m[i])
            i = 0 == i ? generations - 1 : i - 1
        }
        let _ = self.vacate()
        return arr
    }

    /**
     *  The message type offset.
     */
    public var msgTypeOffset: Int {
        return Int(self.msgType.rawValue)
    }

    /**
     *  The index that the next message will be inserted into.
     */
    public var nextIndex: UInt8 {
        return (self.currentIndex + 1) % UInt8(self.generations)
    }

    /**
     *  The message at `nextIndex`.
     */
    public var nextMessage: Message {
        let _ = self.procure()
        let m: Message = self.messages[Int(self.currentIndex) + 1 % self.generations]
        let _ = self.vacate()
        return m
    }

    /**
     *  The number of types currently supported.
     */
    public var numTypes: UInt16 {
        return self.gsw.pointee.num_types
    }

    public var subscribed: UInt16 {
        return self.gsw.pointee.subscribed
    }

    /**
     *  The total number of message types.
     */
    public var totalMessageTypes: Int {
        return Int(GSW_TOTAL_MESSAGE_TYPES)
    }

    /**
     *  The version of the whiteboard.
     */
    public var version: UInt16 {
        return self.gsw.pointee.version
    }

    public init(
        msgType: wb_types,
        wb: Whiteboard = Whiteboard(),
        atomic: Bool = true,
        shouldNotifySubscribers: Bool = true
    ) {
        self.atomic = atomic
        self.msgType = msgType
        self.shouldNotifySubscribers = shouldNotifySubscribers
        self.wb = wb
    }

    /**
     *  Retrieve the latest `Message`.
     *
     *  - Returns: The latest `Message` in the whiteboard.
     */
    public func get() -> Message {
        let _ = self.procure()
        let m: Message = self.wb.get(msg: self.msgType)
        let _ = self.vacate()
        return m
    }

    /**
     *  Signal all the subscribers that a change has happened.
     *
     *  - Precondition: `shouldNotifySubscribers` is true.
     */
    public func notifySubscribers() {
        if (false == self.shouldNotifySubscribers) {
            return
        }
        gsw_signal_subscribers(self.wb.wb)
    }

    /**
     *  Post a new message to the whiteboard.
     *
     *  - Parameter val: The new `Message`.
     */
    public func post(val: Message) {
        if (false == self.procure()) {
            return
        }
        self.wb.post(val: val, msg: self.msgType)
        gsw_increment_event_counter(self.wb.wb, Int32(self.msgType.rawValue))
        let _ = self.vacate()
        self.notifySubscribers()
    }

    /**
     *  Procure the `GSW_SEM_PUTMSG` semaphore.
     *
     *  - Precondition: `atomic` is true.
     *
     *  - Returns: A Bool indicating whether the procurement was successful.
     */
    public func procure() -> Bool {
        if (false == self.atomic || self.procuredCount > 0) {
            self.procuredCount = self.procuredCount + 1
            return true
        }
        let sem = self.wb.wbd.pointee.sem
        let procured: Bool = 0 == gsw_procure(sem, GSW_SEM_PUTMSG)
        if (true == procured) {
            self.procuredCount = self.procuredCount + 1
        }
        return procured
    }

    /**
     *  Vacate the semaphore.
     *
     *  - Precondition: A call to `procure()` was invoked before this.
     *
     *  - Returns: A Bool indicating whether the vacation was successful.
     */
    public func vacate() -> Bool {
        if (false == self.atomic || self.procuredCount > 1) {
            self.procuredCount = self.procuredCount - 1
            return true
        }
        let sem = self.wb.wbd.pointee.sem
        let vacated: Bool = 0 == gsw_vacate(sem, GSW_SEM_PUTMSG)
        if (true == vacated) {
            self.procuredCount = 0
        }
        return vacated
    }

}

/**
 *  Make the GenericWhiteboard a `ExternalVariablesCollection`.
 */
extension GenericWhiteboard: Sequence {

    public typealias Element = Message
    public typealias Iterator = AnyIterator<Element> 

    /**
     *  Returns the messages in the order of `orderedMessages`.
     */
    public func makeIterator() -> AnyIterator<Element> {
        let messages: [Element] = self.orderedMessages
        var i: Int = 0
        return AnyIterator {
            if (i >= messages.count) {
                return nil
            } 
            let j = i
            i = i + 1
            return messages[j]
        } 
    }

}
