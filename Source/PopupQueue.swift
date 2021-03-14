//
//  PopupQueue.swift
//  PopupQueue
//
//  Created by liangliang hu on 2020/9/2.
//  Copyright © 2020 com.liangliang. All rights reserved.
//

import UIKit
import Foundation

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
    PopupLog.default.log("\(popup.popupName) will show.")
    guard popup.popupStatus == .ready || popup.selfMaintain else {
      PopupLog.default.log("\(popup.popupName) can not show repeatedly.")
      return
    }

    var popup = popup
    popup.popupStatus = .willShow

    switch popup.container {
      case .window, .none:
        popup.show()
        PopupLog.default.log("\(popup.popupName) showing.")
      case let .viewController(container):
        if UIViewController.topMost == container {
          popup.show()
          PopupLog.default.log("\(popup.popupName) showing.")
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
    PopupLog.default.log("\(popup.popupName) has been cleared.")
  }
}

extension PopupManager {
  public func register(popup: PopupRequirement, in container: PopContainer) {
    PopupLog.default.log("Popup \(popup.popupName) is registering")
    
    for popupItem in queue.array where popupItem.popupName == popup.popupName {
      PopupLog.default.log("Popup \(popup.popupName) has registered")
      return
    }

    var popup = popup
    popup.container = container
    popup.popupStatus = .ready
    if queue.front?.popupStatus == .showing || queue.front?.popupStatus == .willShow {
      addQueue(popup: popup, exceptFirst: true)
      PopupLog.default.log("\(String(describing:queue.front?.popupName)) is showing, \(popup.popupName) add into queue.")
    } else {
      addQueue(popup: popup)
      PopupLog.default.log("\(popup.popupName) add into queue.")
    }

    PopupLog.default.log("Popup queue front popup \(String(describing:queue.front?.popupName)) status is \(String(describing:queue.front?.popupStatus)).")
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
      PopupLog.default.log("No popup will show.")
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
    PopupLog.default.log("PopupManager pause")

    guard var popup = currentPopup?.popup, !popup.selfMaintain else {
      return
    }

    if popup.popupStatus == .willShow {
      popup.popupStatus = .ready
    }
  }

  // 轮询遍历
  public func poll() {
    PopupLog.default.log("Start poll popups.")

    guard
      let popup = currentPopup?.popup,
      popup.popupStatus != .showing,
      popup.popupStatus != .willShow else {
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
          currentPopup = (index, popup)
          popup.show()
        }
        return
      case let .viewController(container):
        if UIViewController.topMost == container {
          if popup.popupStatus == .ready || popup.selfMaintain {
            if popup.popupStatus == .ready {
              popup.popupStatus = .willShow
            }
            currentPopup = (index, popup)
            popup.show()
          }
          return
        }
      }
    }

    PopupLog.default.log("No popup will show when poll.")
  }
}

