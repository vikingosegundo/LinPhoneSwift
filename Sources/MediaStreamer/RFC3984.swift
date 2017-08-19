//
//  RFC3984.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 8/17/17.
//
//

import CMediaStreamer2.rfc3984

/// Used to pack/unpack H264 nals as described in RFC3984
public final class Rfc3984Context {
    
    public typealias RawPointer = UnsafeMutablePointer<CMediaStreamer2.Rfc3984Context>
    
    // MARK: - Properties
    
    @_versioned
    internal let rawPointer: RawPointer
    
    // MARK: - Initialization
    
    deinit {
        
        rfc3984_destroy(rawPointer)
    }
    
    public init() {
        
        guard let rawPointer = rfc3984_new()
            else { fatalError("Could not create object") }
        
        self.rawPointer = rawPointer
    }
    
    // MARK: - Accessors
    
    public var mode: UInt8 {
        
        @inline(__always)
        get { return rawPointer.pointee.mode }
        
        @inline(__always)
        set { rawPointer.pointee.mode = newValue }
    }
    
    public var isSingleTimeAggregationPacketAEnabled: Bool {
        
        @inline(__always)
        get { return rawPointer.pointee.stap_a_allowed.boolValue }
        
        @inline(__always)
        set { rawPointer.pointee.stap_a_allowed = bool_t(newValue) }
    }
    
    public var maxSize: Int {
        
        @inline(__always)
        get { return Int(rawPointer.pointee.maxsz) }
        
        @inline(__always)
        set { rawPointer.pointee.maxsz = Int32(newValue) }
    }
    
    // MARK: - Methods
    
    public func pack() {
        
        //rfc3984_pack(rawPointer, <#T##naluq: UnsafeMutablePointer<MSQueue>!##UnsafeMutablePointer<MSQueue>!#>, <#T##rtpq: UnsafeMutablePointer<MSQueue>!##UnsafeMutablePointer<MSQueue>!#>, <#T##ts: UInt32##UInt32#>)
    }
}
