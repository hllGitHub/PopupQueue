# PopupQueue
弹框事件队列

* 使用 Swift
* iOS 10.0， Swift 4.0+

## Doc

#### PopupRequirement
这是我们的核心 protocol，所有需要进行队列管理的弹框事件都需要实现该 protocol

``` swift
public protocol PopupRequirement {
  var popupName: String { get }
  var priority: Int { get } // 弹框的优先级
  var container: PopContainer? { set get }
  var popupStatus: PopupStatus? { set get }
  var selfMaintain: Bool { get }  // 业务方自行维护重复弹出问题

  mutating func show()
}
```

#### PopupStatus

``` swift
public enum PopupStatus {
  case ready
  case willShow
  case showing
  case over
}
```

* ready: 初始状态，注册时就会设置成该状态
* willShow: 触发了对应弹框的 `show` 操作，即将弹出
* showing: 正在弹出
* over: 结束了弹框

#### PopContainer

``` swift
public enum PopContainer {
  case viewController(container: UIViewController)
  case window
}
```

应该执行弹框的位置，可以指定页面，也可以设置成 window，可以任意页面弹出

## Usage

### 1. 实现 PopupRequirement 协议

``` swift
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

```

### 2. 注册加入 PopupQueue 

``` swift
    PopupManager.shared.register(popup: DemoAlert1(), in: .viewController(container: self))
```

### 3. 结束弹框事件
关闭弹框时需要主动触发：
``` swift
PopupManager.shared.next()
```

### 4. viewDidAppear 中进行轮询

``` swift
PopupManager.shared.poll()
```

### 5. viewWillDisappear 中进行暂停

``` swift
PopupManager.shared.pause()
```

### 6. 注意点：

* 弹框弹出后将状态置为 `.showing`，比如 
``` swift
topMost.present(alertController, animated: true) {
  self.popupStatus = .showing
}
```

* 弹框如果是异步弹出，那么在弹出前请校验一下状态，比如：
``` swift
guard popupStatus == .willShow else {
  return
}
```
* 弹框的类型并不没有要求，可以是 UIAlertViewController，自定义 view，音频播放器，等等，只要属于弹出事件都可以
* 如果声明 `selfMaintain` 为true，则除非主动调用 `PopupManager.shared.next()`，PopupQueue 才会将其 Remove，并且执行下一个弹框事件
* 更多示例请参考工程 Demo
