# Synchronization in Swift

Swift has no synchornozation functionality in the language,
but Foundation framework is available to synchronize the code.

## Use of `dispatch_sync()`

```swift
class Foo {
  var value = 0
  let sync = dispatch_queue_create("\(self.dynamicType).sync", DISPATCH_QUEUE_SERIAL)

  func incrementWithSerialQueue() {
      dispatch_sync(sync) {
          self.value += 1
      }
  }

```

## Use of `objc_sync_enter()` and `objc_sync_exit()`

```swift
class AutoSync {
    let object : AnyObject

    init(_ obj : AnyObject) {
        object = obj
        objc_sync_enter(object)
    }

    deinit {
        objc_sync_exit(object)
    }
}

class Foo {
  var value = 0

  func incrementWithObjcSync() {
      let lock = AutoSync(self)
      self.value += 1
  }
}
```
