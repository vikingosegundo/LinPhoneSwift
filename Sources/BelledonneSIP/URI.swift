//
//  URI.swift
//  LinPhone
//
//  Created by Alsey Coleman Miller on 7/3/17.
//
//

import CBelledonneSIP

/// Generic URI used with Belledonne libraries (e.g. Linphone).
public struct URI: RawRepresentable {
    
    // MARK: - Properties
    
    @_versioned // private(set) in Swift 4
    internal fileprivate(set) var internalReference: CopyOnWrite<Reference>
    
    // MARK: - Initialization
    
    @inline(__always)
    internal init(_ internalReference: CopyOnWrite<Reference>) {
        
        self.internalReference = internalReference
    }
    
    /// Initialize an empty URI.
    public init() {
        
        self.init(referencing: Reference())
    }
    
    /// Initialize an URI from a string.
    public init?(rawValue: String) {
        
        guard let reference = Reference(string: rawValue)
            else { return nil }
        
        self.init(referencing: reference)
    }
    
    // MARK: - Accessors
    
    public var rawValue: String {
        
        get { return internalReference.reference.description }
    }
    
    public var scheme: String? {
        
        get { return internalReference.reference.getString(belle_generic_uri_get_scheme) }
        
        mutating set { internalReference.mutatingReference.setString(belle_generic_uri_set_scheme, newValue) }
    }
    
    public var user: String? {
        
        get { return internalReference.reference.getString(belle_generic_uri_get_user) }
        
        mutating set { internalReference.mutatingReference.setString(belle_generic_uri_set_user, newValue) }
    }
    
    public var password: String? {
        
        get { return internalReference.reference.getString(belle_generic_uri_get_user_password) }
        
        mutating set { internalReference.mutatingReference.setString(belle_generic_uri_set_user_password, newValue) }
    }
    
    public var host: String? {
        
        get { return internalReference.reference.getString(belle_generic_uri_get_host) }
        
        mutating set { internalReference.mutatingReference.setString(belle_generic_uri_set_host, newValue) }
    }
    
    public var path: String? {
        
        get { return internalReference.reference.getString(belle_generic_uri_get_path) }
        
        mutating set { internalReference.mutatingReference.setString(belle_generic_uri_set_path, newValue) }
    }
    
    public var query: String? {
        
        get { return internalReference.reference.getString(belle_generic_uri_get_query) }
        
        mutating set { internalReference.mutatingReference.setString(belle_generic_uri_set_query, newValue) }
    }
    
    public var port: Int32 {
        
        get { return belle_generic_uri_get_port(internalReference.reference.rawPointer) }
        
        mutating set { belle_generic_uri_set_port(internalReference.mutatingReference.rawPointer, newValue) }
    }
}

// MARK: - Equatable

extension URI: Equatable {
    
    public static func == (lhs: URI, rhs: URI) -> Bool {
        
        return lhs.rawValue == rhs.rawValue
    }
}

// MARK: - Hashable

extension URI: Hashable {
    
    public var hashValue: Int {
        
        @inline(__always)
        get { return rawValue.hashValue }
    }
}

// MARK: - CustomStringConvertible

extension URI: CustomStringConvertible {
    
    public var description: String {
        
        @inline(__always)
        get { return rawValue }
    }
}

// MARK: - BelledonneObject

extension URI: BelledonneObject {
    
    public typealias RawPointer = OpaquePointer
    
    public mutating func withUnsafeMutableRawPointer <Result> (_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.mutatingReference.rawPointer
        
        return try body(rawPointer)
    }
    
    public func withUnsafeRawPointer <Result> (_ body: (OpaquePointer) throws -> Result) rethrows -> Result {
        
        let rawPointer = internalReference.reference.rawPointer
        
        return try body(rawPointer)
    }
}

// MARK: - ReferenceConvertible

extension URI: ReferenceConvertible {
    
    internal final class Reference: BelledonneObjectHandle {
        
        internal typealias UnmanagedPointer = BelledonneUnmanagedObject
        
        internal typealias RawPointer = UnmanagedPointer.RawPointer
        
        // MARK: - Properties
        
        @_versioned
        internal let managedPointer: ManagedPointer<UnmanagedPointer>
        
        // MARK: - Initialization
        
        internal init(_ managedPointer: ManagedPointer<UnmanagedPointer>) {
            
            self.managedPointer = managedPointer
        }
        
        convenience init() {
            
            guard let rawPointer = belle_generic_uri_new()
                else { fatalError("Could not allocate instance") }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        }
        
        convenience init?(string: String) {
            
            guard let rawPointer = belle_generic_uri_parse(string)
                else { return nil }
            
            self.init(ManagedPointer(UnmanagedPointer(rawPointer)))
        }
    }
}
