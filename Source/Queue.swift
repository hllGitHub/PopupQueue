//
//  Queue.swift
//  PopupQueue
//
//  Created by Jeffrey hu on 2021/3/14.
//  Copyright © 2021 com.liangliang. All rights reserved.
//

import Foundation

public struct Queue<T> {
  private var rwLock = os_unfair_lock_s()

  var array = [T]()
  public var isEmpty: Bool {
    return array.isEmpty
  }
  public var count: Int {
    return array.count
  }
  public mutating func enqueue(_ element: T, by areInIncreasingOrder: (T, T) throws -> Bool, exceptFirst: Bool) {
    enqueue(element)

    os_unfair_lock_lock(&rwLock)
    if exceptFirst && array.count > 1 {
      let array1 = array[0...0]
      var array2 = array[1...array.count - 1]
      try? array2.sort(by: areInIncreasingOrder)
      array = Array(array1) + Array(array2)
    } else {
      try? array.sort(by: areInIncreasingOrder)
    }
    os_unfair_lock_unlock(&rwLock)
  }
  public mutating func enqueue(_ element: T) {
    os_unfair_lock_lock(&rwLock)
    array.append(element)
    os_unfair_lock_unlock(&rwLock)
  }
  public mutating func dequeue() -> T? {
    if isEmpty {
      return nil
    } else {
      return array.removeFirst()
    }
  }
  public mutating func dequeue(at index: Int) -> T? {
    if isEmpty || index > array.count - 1 {
      return nil
    } else {
      os_unfair_lock_lock(&rwLock)
      let element = array.remove(at: index)
      os_unfair_lock_unlock(&rwLock)
      return element
    }
  }
  public var front: T? {
    return array.first
  }
}
