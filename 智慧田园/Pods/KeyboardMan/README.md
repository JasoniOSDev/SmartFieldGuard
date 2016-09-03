<p>
<a href="http://cocoadocs.org/docsets/KeyboardMan"><img src="https://img.shields.io/cocoapods/v/KeyboardMan.svg?style=flat"></a> 
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a> 
</p>

# KeyboardMan

We may need keyboard infomation from keyboard notification to do animation. However, the approach is complicated and easy to make mistakes. 

But KeyboardMan will make it simple & easy.

## Requirements

Swift 2.2, iOS 8.0

## Example

```swift
import KeyboardMan
```

Do animation with keyboard appear/disappear:

```swift
let keyboardMan = KeyboardMan()

keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in

    print("appear \(appearPostIndex), \(keyboardHeight), \(keyboardHeightIncrement)\n")

    if let strongSelf = self {

        strongSelf.tableView.contentOffset.y += keyboardHeightIncrement
        strongSelf.tableView.contentInset.bottom = keyboardHeight + strongSelf.toolBar.frame.height

        strongSelf.toolBarBottomConstraint.constant = keyboardHeight
        strongSelf.view.layoutIfNeeded()
    }
}

keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in

    print("disappear \(keyboardHeight)\n")

    if let strongSelf = self {

        strongSelf.tableView.contentOffset.y -= keyboardHeight
        strongSelf.tableView.contentInset.bottom = strongSelf.toolBar.frame.height

        strongSelf.toolBarBottomConstraint.constant = 0
        strongSelf.view.layoutIfNeeded()
    }
}
```

For more specific information, you can use keyboardInfo that KeyboardMan post:

```swift
keyboardMan.postKeyboardInfo = { [weak self] keyboardMan, keyboardInfo in
	// TODO
}
```

Check the demo for more information.

另有[中文介绍](https://github.com/nixzhu/dev-blog/blob/master/2015-07-27-keyboard-man.md)。

## Installation

Feel free to drag `KeyboardMan.swift` to your iOS Project. But it's recommended to use CocoaPods or Carthage.

### CocoaPods

```ruby
pod 'KeyboardMan', '~> 0.6.1'
```

### Carthage

```ogdl
github "nixzhu/KeyboardMan" >= 0.6.1
```

## Contact

NIX [@nixzhu](https://twitter.com/nixzhu)

## License

KeyboardMan is available under the MIT license. See the LICENSE file for more info.
