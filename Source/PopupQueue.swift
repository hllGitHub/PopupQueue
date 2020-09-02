//
//  PopupQueue.swift
//  PopupQueue
//
//  Created by liangliang hu on 2020/9/2.
//  Copyright © 2020 com.liangliang. All rights reserved.
//

import UIKit
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

public enum PopContainer {
  case viewController(container: UIViewController)
  case window
}

public enum PopupStatus {
  case ready
  case willShow
  case showing
  case over
}

public protocol PopupRequirement {
  var popupName: String { get }
  var priority: Int { get } // 弹框的优先级
  var container: PopContainer? { set get }
  var popupStatus: PopupStatus? { set get }
  var selfMaintain: Bool { get }  // 业务方自行维护重复弹出问题

  mutating func show()
}

public class PopupManager {
  static let logTag = "PopupManager"
  public static var shared = PopupManager()

  /// Config
  // `autoPollWhenRegistered` 默认为 true，即注册的第一个 popup，默认会执行 show 操作
  public var autoPollWhenRegistered = true

  private var queue: Queue<PopupRequirement> = Queue()
  private var currentPopup: (index: Int, popup: PopupRequirement)?
  private var isShowing: Bool = false

  private func addQueue(popup: PopupRequirement, exceptFirst: Bool = false) {
    queue.enqueue(popup, by: { $0.priority > $1.priority }, exceptFirst: exceptFirst)
  }

  private func show(popup: PopupRequirement) {
    print("\(popup.popupName) will show.", PopupManager.logTag)
    guard popup.popupStatus == .ready || popup.selfMaintain else {
      print("\(popup.popupName) can not show repeatedly.", PopupManager.logTag)
      return
    }

    var popup = popup
    popup.popupStatus = .willShow

    switch popup.container {
      case .window, .none:
        popup.show()
        print("\(popup.popupName) showing.", PopupManager.logTag)
      case let .viewController(container):
        if UIViewController.topMost == container {
          popup.show()
          print("\(popup.popupName) showing.", PopupManager.logTag)
          return
      }
    }
  }

  private func clearPopup(index: Int) {
    guard index < queue.array.count else {
      return
    }
    var popup = queue.array[index]
    popup.popupStatus = .over
    _ = queue.dequeue(at: index)
    print("\(popup.popupName) has been cleared.", PopupManager.logTag)
  }
}

extension PopupManager {
  public func register(popup: PopupRequirement, in container: PopContainer) {
    print("Popup \(popup.popupName) is registering", PopupManager.logTag)

    if queue.array.first(where: { (popupItem) -> Bool in
      return popupItem.popupName == popup.popupName
    }) != nil {
      print("Popup \(popup.popupName) has registered", PopupManager.logTag)
      return
    }

    var popup = popup
    popup.container = container
    popup.popupStatus = .ready
    if queue.front?.popupStatus == .showing || queue.front?.popupStatus == .willShow {
      addQueue(popup: popup, exceptFirst: true)
      print("\(String(describing:queue.front?.popupName)) is showing, \(popup.popupName) add into queue.", PopupManager.logTag)
    } else {
      addQueue(popup: popup)
      print("\(popup.popupName) add into queue.", PopupManager.logTag)
    }

    print("Popup queue front popup \(String(describing:queue.front?.popupName)) status is \(String(describing:queue.front?.popupStatus)).", PopupManager.logTag)
    // Show popup when the front not showing
    if queue.front?.popupStatus == .ready && autoPollWhenRegistered {
      show()
    }
  }

  public func clear() {
    queue = Queue()
  }

  // 开始 show
  public func show() {
    guard let popup = queue.front else {
      print("No popup will show.", PopupManager.logTag)
      return
    }

    currentPopup = (0, popup)
    show(popup: popup)
  }

  public func next() {
    if let index = currentPopup?.index {
      clearPopup(index: index)
    } else {
      clearPopup(index: 0)
    }

    show()
  }

  // 重置
  public func pause() {
    print("PopupManager pause", PopupManager.logTag)

    guard var popup = currentPopup?.popup, !popup.selfMaintain else {
      return
    }

    if popup.popupStatus == .willShow {
      popup.popupStatus = .ready
    }
  }

  // 轮询遍历
  public func poll() {
    print("Start poll popups.", PopupManager.logTag)

    guard let popup = currentPopup?.popup, popup.popupStatus != .showing, popup.popupStatus != .willShow else {
      return
    }

    for (index, popup) in queue.array.enumerated() {
      var popup = popup
      switch popup.container {
      case .window, .none:
        if popup.popupStatus == .ready || popup.selfMaintain {
          if popup.popupStatus == .ready {
            popup.popupStatus = .willShow
          }
          popup.show()
          if popup.popupName != currentPopup?.popup.popupName {
            currentPopup?.popup.popupStatus = .ready
          }

          currentPopup = (index, popup)
        }
        return
      case let .viewController(container):
        if UIViewController.topMost == container {
          if popup.popupStatus == .ready || popup.selfMaintain {
            if popup.popupStatus == .ready {
              popup.popupStatus = .willShow
            }
            popup.show()
            currentPopup = (index, popup)
          }
          return
        }
      }
    }

    print("No popup will show when poll.", PopupManager.logTag)
  }
}

