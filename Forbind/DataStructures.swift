//
//  Result.swift
//  BindTest
//
//  Created by Ulrik Damm on 30/01/15.
//  Copyright (c) 2015 Ufd.dk. All rights reserved.
//

import Foundation

let bindErrorDomain = "dk.ufd.Forbind"

enum bindErrors : Int {
	case CombinedError = 1
	case NilError = 2
}

let resultNilError = NSError(domain: bindErrorDomain, code: bindErrors.NilError.rawValue, userInfo: [NSLocalizedDescriptionKey: "Nil result"])

public class Box<T> {
	public let value : T
	
	public init(_ value : T) {
		self.value = value
	}
}

public enum Result<T> {
	case Ok(Box<T>)
	case Error(NSError)
	
	init(_ value : T) {
		self = .Ok(Box(value))
	}
	
	init(_ error : NSError) {
		self = .Error(error)
	}
}


public class Promise<T> {
	public init() {
		
	}
	
	public init(value : T) {
		self._value = value
	}
	
	public func setValue(value : T) {
		_value = value
	}
	
	private(set) var _value : T? {
		didSet {
			notifyListeners()
		}
	}
	
	private var listeners : [T -> Void] = []
	
	public func getValue(callback : T -> Void) {
		if let value = _value {
			callback(value)
		} else {
			listeners.append(callback)
		}
	}
	
	private func notifyListeners() {
		for callback in listeners {
			callback(_value!)
		}
		
		listeners = []
	}
}


public class OptionalPromise<T> {
	public init() {
		
	}
	
	public init(value : T?) {
		self.value = value
	}
	
	public func setValue(value : T?) {
		self.value = value
	}
	
	public func setSomeValue(value : T) {
		self.value = value
	}
	
	public func setNil() {
		self.value = .Some(nil)
	}
	
	private(set) var value : T?? {
		didSet {
			notifyListeners()
		}
	}
	
	private var listeners : [T? -> Void] = []
	
	public func getValue(callback : T? -> Void) {
		if let value = value {
			callback(value)
		} else {
			listeners.append(callback)
		}
	}
	
	private func notifyListeners() {
		for callback in listeners {
			callback(value!)
		}
		
		listeners = []
	}
}

public class ResultPromise<T> {
	public init() {
		
	}
	
	public init(value : Result<T>) {
		self.value = value
	}
	
	public func setValue(value : Result<T>) {
		self.value = value
	}
	
	public func setOkValue(value : T) {
		setValue(.Ok(Box(value)))
	}
	
	public func setError(error : NSError) {
		setValue(.Error(error))
	}
	
	private(set) var value : Result<T>? {
		didSet {
			notifyListeners()
		}
	}
	
	private var listeners : [Result<T> -> Void] = []
	
	public func getValue(callback : Result<T> -> Void) {
		if let value = value {
			callback(value)
		} else {
			listeners.append(callback)
		}
	}
	
	private func notifyListeners() {
		for callback in self.listeners {
			callback(self.value!)
		}
		
		self.listeners = []
	}
}
