//
//  Extension.swift
//  PopupQueue
//
//  Created by liangliang hu on 2020/9/2.
//  Copyright © 2020 com.liangliang. All rights reserved.
//

import UIKit

extension UIViewController {
  /// Returns the current application's top most view controller.
  open class var topMost: UIViewController? {
    let currentWindows = UIApplication.shared.windows
    var rootViewController: UIViewController?
    for window in currentWindows {
      if let windowRootViewController = window.rootViewController {
        rootViewController = windowRootViewController
        break
      }
    }
    let viewController = topMost(of: rootViewController)
    print("get topMost viewController: \(String(describing: viewController))")
    return viewController
  }

  /// Returns the top most view controller from given view controller's stack.
  open class func topMost(of viewController: UIViewController?) -> UIViewController? {
    // presented view controller
    if let presentedViewController = viewController?.presentedViewController {
      return topMost(of: presentedViewController)
    }

    // UITabBarController
    if let tabBarController = viewController as? UITabBarController,
      let selectedViewController = tabBarController.selectedViewController
    {
      return topMost(of: selectedViewController)
    }

    // UINavigationController
    if let navigationController = viewController as? UINavigationController,
      let visibleViewController = navigationController.visibleViewController
    {
      return topMost(of: visibleViewController)
    }

    // UIPageController
    if let pageViewController = viewController as? UIPageViewController,
      pageViewController.viewControllers?.count == 1
    {
      return topMost(of: pageViewController.viewControllers?.first)
    }

    // child view controller
    for subview in viewController?.view?.subviews ?? [] {
      if let childViewController = subview.next as? UIViewController {
        return topMost(of: childViewController)
      }
    }

    return viewController
  }
}

