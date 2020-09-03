//
//  DemoAlert1.swift
//  PopupQueue
//
//  Created by liangliang hu on 2020/9/2.
//  Copyright © 2020 com.liangliang. All rights reserved.
//

import UIKit

class DemoAlert1: PopupRequirement {
  var selfMaintain: Bool {
    return false
  }

  var popupStatus: PopupStatus?

  var popupName: String {
    return "DemoAlert1"
  }

  var priority: Int {
    return 100
  }

  var container: PopContainer?

  func show() {
    guard popupStatus == .willShow else {
      return
    }

    guard let topMost = UIViewController.topMost else {
      return
    }

    let alertController = UIAlertController(title: "Alert1", message: "This is an alert.", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
      print("You've pressed default")
      PopupManager.shared.next()
    }
    alertController.addAction(okAction)
    topMost.present(alertController, animated: true) {
      self.popupStatus = .showing
    }
  }
}
