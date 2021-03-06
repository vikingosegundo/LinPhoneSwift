//
//  LinkedList.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/2/17.
//
//

#if os(macOS) || os(iOS)
    import Darwin.C
#elseif os(Linux)
    import Glibc
#endif

import CBelledonneToolbox.list
import struct Foundation.Data
import class Foundation.NSMutableData

/// Linked List structure
public struct LinkedList {
    
    // MARK: - Properties
    
    @_versioned
    internal let internalReference: Reference?
    
    // MARK: - Initialization
    
    internal init(_ internalReference: Reference?) {
        
        self.internalReference = internalReference
    }
    
    /// Initialize linked list from a data array.
    public init(data: [Data]) {
        
        let mutableData = data.map { NSMutableData(data: $0) }
        
        self.init(Reference(mutableData: mutableData))
    }
    
    /// Initialize linked list from a string array.
    public init(strings: [String]) {
        
        self.init(Reference(strings: strings))
    }
    
    // MARK: - Accessors
    
    /// Get the value as a string.
    public var strings: [String] {
        
        return internalReference?.data.map { String(cStringData: $0) } ?? []
    }
    
    /// Get the linked list data.
    public var data: [Data] {
        
        return internalReference?.data.map { Data(referencing: $0) } ?? []
    }
    
    public var isEmpty: Bool {
        
        return internalReference == nil
    }
    
    // MARK: - Accessors
    
    /// Access the underlying C structure instance with read-only access.
    ///
    /// - Warning: The pointer is only guarenteed to be valid for the lifetime of the closure. 
    /// Do not attempt to use the pointer outside of the closure, or attempt to mutate it in any way.
    public func withUnsafeRawPointer <Result> (_ body: (UnsafePointer<bctbx_list_t>?) throws -> Result) rethrows -> Result {
        
        let rawPointer: UnsafePointer<bctbx_list_t>?
        
        if let reference = self.internalReference {
            
            rawPointer = UnsafePointer(reference.rawPointer)
            
        } else {
            
            rawPointer = nil
        }
        
        return try body(rawPointer)
    }
}

// MARK: - Equatable

extension LinkedList: Equatable {
    
    public static func == (lhs: LinkedList, rhs: LinkedList) -> Bool {
        
        return (lhs.internalReference?.data ?? []) == (rhs.internalReference?.data ?? [])
    }
}

// MARK: - Hashable

extension LinkedList: Hashable {
    
    public var hashValue: Int {
        
        return description.hashValue
    }
}

// MARK: - CustomStringConvertible

extension LinkedList: CustomStringConvertible {
    
    public var description: String {
        
        return "\(strings)"
    }
}

// MARK: - 

public extension LinkedList {
    
    /// Extract the string values from a linked list raw pointer.
    public static func strings(from rawPointer: UnsafePointer<bctbx_list_t>) -> [String] {
        
        let count = bctbx_list_size(rawPointer)
        
        var values = [String]()
        values.reserveCapacity(count)
        
        for index in 0 ..< count {
            
            guard let dataPointer = bctbx_list_nth_data(rawPointer, Int32(index))
                else { fatalError("No data for linked list at index \(index)") }
            
            let cString = dataPointer.assumingMemoryBound(to: CChar.self)
            
            let element = String(cString: cString)
            
            values.append(element)
        }
        
        return values
    }
}

// MARK: - Reference

extension LinkedList {
    
    internal final class Reference: Handle {
        
        typealias RawPointer = UnsafeMutablePointer<bctbx_list_t>
        
        // MARK: - Properties
        
        /// Underlying `bctbx_list_t` pointer. Always the first element.
        @_versioned
        internal let rawPointer: RawPointer
        
        /// Keep reference for ARC. `bctbx_list_t` only manages memory of list structure, not the attached data. WTF?
        @_versioned
        internal let data: [NSMutableData]
        
        // MARK: - Initialization
        
        deinit {
            
            bctbx_list_free(rawPointer)
        }
        
        fileprivate init?(mutableData: [NSMutableData]) {
            
            guard let firstData = mutableData.first,
                let rawPointer = bctbx_list_new(firstData.mutableBytes)
                else { return nil }
            
            /// append other data.
            for data in mutableData.suffix(from: 1) {
                
                bctbx_list_append(rawPointer, data.mutableBytes)
            }
            
            self.rawPointer = rawPointer
            self.data = mutableData
        }
        
        convenience init?(strings: [String]) {
            
            // convert strings to data
            
            let data = strings.map { $0.cStringData }
            
            self.init(mutableData: data)
        }
    }
}

// MARK: - Private Extensions

fileprivate extension String {
    
    var cStringData: NSMutableData {
        
        return self.withCString { NSMutableData(bytes: $0, length: Int(strlen($0)) + 1) }
    }
    
    init(cStringData data: NSMutableData) {
        
        self.init(cString: data.mutableBytes.assumingMemoryBound(to: UInt8.self))
    }
}
