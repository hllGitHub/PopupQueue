//
//  DemoAlert3.swift
//  PopupQueue
//
//  Created by liangliang hu on 2020/9/2.
//  Copyright © 2020 com.liangliang. All rights reserved.
//

import UIKit

class DemoAlert3: PopupRequirement {
  var selfMaintain: Bool {
    return false
  }

  var popupStatus: PopupStatus?

  var popupName: String {
    return "DemoAlert3"
  }

  var priority: Int {
    return 300
  }

  var container: PopContainer?

  func show() {
    // 模拟网络请求或者其他事务处理
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      self.showAlert()
    }
  }
}

extension DemoAlert3 {
  func showAlert() {
    guard let topMost = UIViewController.topMost else {
      return
    }

    guard popupStatus == .willShow || popupStatus == .showing else {
      return
    }

    let alertController = UIAlertController(title: "Alert3", message: "This is an actionSheet.", preferredStyle: .actionSheet)

    let action1 = UIAlertAction(title: "Default", style: .default) { (action:UIAlertAction) in
      print("You've pressed default")
      PopupManager.shared.next()
    }

    let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
      print("You've pressed cancel")
      PopupManager.shared.next()
    }

    let action3 = UIAlertAction(title: "Destructive", style: .destructive) { (action:UIAlertAction) in
      print("You've pressed the destructive")
      PopupManager.shared.next()
    }

    alertController.addAction(action1)
    alertController.addAction(action2)
    alertController.addAction(action3)
    topMost.present(alertController, animated: true) {
      self.popupStatus = .showing
    }
//    popupStatus = .showing
  }
}
