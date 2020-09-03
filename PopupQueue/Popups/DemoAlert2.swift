//
//  DemoAlert2.swift
//  PopupQueue
//
//  Created by liangliang hu on 2020/9/2.
//  Copyright © 2020 com.liangliang. All rights reserved.
//

import UIKit

class DemoAlert2: PopupRequirement {
  var selfMaintain: Bool {
    return false
  }

  var popupStatus: PopupStatus?

  var popupName: String {
    return "DemoAlert2"
  }

  var priority: Int {
    return 200
  }

  var container: PopContainer?

  func show() {
    // 模拟网络请求或者其他事务处理
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.showAlert()
    }
  }
}

extension DemoAlert2 {
  func showAlert() {
    guard popupStatus == .willShow else {
      return
    }
    
    guard let topMost = UIViewController.topMost else {
      return
    }

    let alertController = UIAlertController(title: "Alert2", message: "This is an alert.", preferredStyle: .alert)

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
  }
}
