//
//  SecondViewController.swift
//  PopupQueue
//
//  Created by liangliang hu on 2020/9/2.
//  Copyright © 2020 com.liangliang. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    PopupManager.shared.poll()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    PopupManager.shared.pause()
  }
}
