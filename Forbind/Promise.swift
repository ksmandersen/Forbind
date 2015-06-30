//
//  Promise.swift
//  Forbind
//
//  Created by Ulrik Damm on 06/06/15.
//
//

import Foundation

private enum PromiseState<T> {
	case NoValue
	case Value(Box<T>)
}

public class Promise<T> {
	public init(value : T? = nil) {
		value => setValue
	}
	
	private var _value : PromiseState<T> = .NoValue
	var previousPromise : AnyObject?
	
	public func setValue(value : T) {
		_value = PromiseState.Value(Box(value))
		notifyListeners()
	}
	
	public var value : T? {
		get {
			switch _value {
			case .NoValue: return nil
			case .Value(let box): return box.value
			}
		}
	}
	
	private var listeners : [T -> Void] = []
	
	public func getValue(callback : T -> Void) {
		getValueWeak { value in
			self
			callback(value)
		}
	}
	
	public func getValueWeak(callback : T -> Void) {
		if let value = value {
			callback(value)
		} else {
			listeners.append(callback)
		}
	}
	
	private func notifyListeners() {
		switch _value {
		case .NoValue: break
		case .Value(let box):
			for callback in listeners {
				callback(box.value)
			}
		}
		
		listeners = []
	}
}

public func ==<T : Equatable>(lhs : Promise<T>, rhs : Promise<T>) -> Promise<Bool> {
	return (lhs ++ rhs) => { $0 == $1 }
}

public func ==<T : Equatable>(lhs : Promise<T?>, rhs : Promise<T?>) -> Promise<Bool?> {
	return (lhs ++ rhs) => { $0 == $1 }
}

public func ==<T : Equatable>(lhs : Promise<Result<T>>, rhs : Promise<Result<T>>) -> Promise<Result<Bool>> {
	return (lhs ++ rhs) => { $0 == $1 }
}

extension Promise : Printable {
	public var description : String {
		if let value = value {
			return "Promise(\(value))"
		} else {
			return "Promise(\(T.self))"
		}
	}
}

public func filterp<T>(source : [Promise<T>], includeElement : T -> Bool) -> Promise<[T]> {
	return reducep(source, []) { all, this in includeElement(this) ? all + [this] : all }
}

public func reducep<T, U>(source : [Promise<T>], initial : U, combine : (U, T) -> U) -> Promise<U> {
	return reduce(source, Promise(value: initial)) { $0 ++ $1 => combine }
}

//public func mapp<T, U>(source : [T], mapping : T -> U) -> [U] {
//	return map(source, mapping)
//}
//
//public func =><T, U>(source : [T], mapping : T -> U) -> [U] {
//	return mapp(source, mapping)
//}
//
//public func mapp<T, U>(source : [T?], mapping : T -> U) -> [U?] {
//	return map(source) { $0 => mapping }
//}
//
//public func =><T, U>(source : [T?], mapping : T -> U) -> [U?] {
//	return mapp(source, mapping)
//}
//
//public func mapp<T, U>(source : [Result<T>], mapping : T -> U) -> [Result<U>] {
//	return map(source) { $0 => mapping }
//}
//
//public func =><T, U>(source : [Result<T>], mapping : T -> U) -> [Result<U>] {
//	return mapp(source, mapping)
//}
//
//public func mapp<T, U>(source : [Promise<T>], mapping : T -> U) -> [Promise<U>] {
//	return map(source) { $0 => mapping }
//}
//
//public func =><T, U>(source : [Promise<T>], mapping : T -> U) -> [Promise<U>] {
//	return mapp(source, mapping)
//}
//
//public func mapp<T, U>(source : [Promise<T?>], mapping : T -> U) -> [Promise<U?>] {
//	return map(source) { $0 => mapping }
//}
//
//public func =><T, U>(source : [Promise<T?>], mapping : T -> U) -> [Promise<U?>] {
//	return mapp(source, mapping)
//}
//
//public func mapp<T, U>(source : [Promise<Result<T>>], mapping : T -> U) -> [Promise<Result<U>>] {
//	return map(source) { $0 => mapping }
//}
//
//public func =><T, U>(source : [Promise<Result<T>>], mapping : T -> U) -> [Promise<Result<U>>] {
//	return mapp(source, mapping)
//}
