<p>
<a href="http://cocoadocs.org/docsets/KeyboardMan"><img src="https://img.shields.io/cocoapods/v/KeyboardMan.svg?style=flat"></a> 
<a href="https://github.com/Carthage/Carthage/"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a> 
</p>

# KeyboardMan

We may need keyboard infomation from keyboard notification to do animation. However, the approach is complicated and easy to make mistakes. 

But KeyboardMan will make it simple & easy.

## Requirements

Swift 2.0, iOS 8.0

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

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects.

CocoaPods 0.3.16 adds supports for Swift and embedded frameworks. You can install it with the following command:

```bash
$ [sudo] gem install cocoapods
```

To integrate KeyboardMan into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'KeyboardMan', '~> 0.6.0'
```

Then, run the following command:

```bash
$ pod install
```

You should open the `{Project}.xcworkspace` instead of the `{Project}.xcodeproj` after you installed anything from CocoaPods.

For more information about how to use CocoaPods, I suggest [this tutorial](http://www.raywenderlich.com/64546/introduction-to-cocoapods-2).

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager for Cocoa application. To install the carthage tool, you can use [Homebrew](http://brew.sh).

```bash
$ brew update
$ brew install carthage
```

To integrate KeyboardMan into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "nixzhu/KeyboardMan" >= 0.6.0
```

Then, run the following command to build the KeyboardMan framework:

```bash
$ carthage update
```

At last, you need to set up your Xcode project manually to add the KeyboardMan framework.

On your application targets’ “General” settings tab, in the “Linked Frameworks and Libraries” section, drag and drop each framework you want to use from the Carthage/Build folder on disk.

On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:

```
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks you want to use under “Input Files”:

```
$(SRCROOT)/Carthage/Build/iOS/KeyboardMan.framework
```

For more information about how to use Carthage, please see its [project page](https://github.com/Carthage/Carthage).

## Contact

NIX [@nixzhu](https://twitter.com/nixzhu)

## License

KeyboardMan is available under the MIT license. See the LICENSE file for more info.
