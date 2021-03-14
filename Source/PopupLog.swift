//
//  PopupLog.swift
//  PopupQueue
//
//  Created by Jeffrey hu on 2021/3/14.
//  Copyright © 2021 com.liangliang. All rights reserved.
//

import Foundation

/// PopupLog
public class PopupLog {
  public static var `default` = PopupLog { string in
    #if DEBUG
    print(string)
    #endif
  }
  
  private let output: (String) -> Void
  
  public init(output: @escaping (String) -> Void) {
    self.output = output
  }
  
  public func log(_ message: @autoclosure ()-> String) {
    output("[PopupQueue]: \(message())")
  }
}
