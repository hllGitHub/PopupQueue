//
//  ViewController.swift
//  PopupQueue
//
//  Created by liangliang hu on 2020/9/1.
//  Copyright © 2020 com.liangliang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .cyan

    DispatchQueue.main.async {
      self.registerPopups()
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    PopupManager.shared.poll()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    PopupManager.shared.pause()
  }

  func registerPopups() {
    PopupManager.shared.register(popup: DemoAlert1(), in: .viewController(container: self))
    PopupManager.shared.register(popup: DemoAlert2(), in: .viewController(container: self))
    PopupManager.shared.register(popup: DemoAlert3(), in: .window)
  }
}

