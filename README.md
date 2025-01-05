# TMSwipeActions (SwiftUI)
<br/>
<img src= "https://raw.githubusercontent.com/Rayllienstery/TMMediaStorage/main/TMSwipeActions/TMSwipeActionsIcon.png" width="256" >

## Features

- [x] Leading and Trailing gesture for the any SwiftUIView
- [x] Prolonged gesture to activate an edge action
- [x] Managing visibility without relying on a gesture, using a flag.
- [x] Customization of the font, width, color, icon/text of action buttons.

## Requirements

- iOS 15.0+
- Xcode 16+

## Installation

### Swift Package Manager

To install Lottie using [Swift Package Manager](https://github.com/swiftlang/swift-package-manager) you can follow the [tutorial published by Apple](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) using the URL for the Lottie repo with the current version:

- In Xcode, select “File” -> “Add Packages...”
- Enter the repository path https://github.com/Rayllienstery/TMSwipeActions

or you can add the following dependency to your `Package.swift`:

```swift
.package(url: "https://github.com/Rayllienstery/TMSwipeActions", from: "0.1.0")
```


## Usage example

<img src= "https://raw.githubusercontent.com/Rayllienstery/TMMediaStorage/main/TMSwipeActions/Promo_2.png" width="512" >

#### Just add swipe gestures for the any View
It supports buttons with the text content

```swift
import TMSwipeActions

Button { ...action } label: { ...views }
.leadingSwipe([
    .init(title: "Just", color: .darkBlue, action: { print("Just on tap") })
])

Button { ...action } label: { ...views }
.trailingSwipe([
    .init(title: "Useful", color: .darkBlue, action: {})
])

Button { ...action } label: { ...views }
.swipeActions(leadingActions: [
    .init(title: "Just", color: .darkBlue, action: {})
], trailingActions: [
    .init(title: "Useful", color: .darkBlue, action: {})
])
```
<img src= "https://raw.githubusercontent.com/Rayllienstery/TMMediaStorage/main/TMSwipeActions/Promo_1.png" width="512" >

### And UIImage symbols
***
```swift
Button { ...action } label: { ...views }
.swipeActions(leadingActions: [ ], 
              trailingActions: [
                .init(icon: UIImage(systemName: "square.and.arrow.up")!, color: .darkBlue, action: {}),
                .init(icon: UIImage(systemName: "pencil")!, color: .darkBlueSecondary, action: {}),
                .init(icon: UIImage(systemName: "bookmark")!, color: .darkBlueTertiary, action: {})
                    ])
```

<img src= "https://raw.githubusercontent.com/Rayllienstery/TMMediaStorage/main/TMSwipeActions/Promo_3.png" width="512" >

## Customisation
Use viewConfig to change the width and font, or to disable prolonged swipe.<br>
Also you can pass flags to controll current actions View state

```swift
@State var leadingContentIsPresented: Bool = false
@State var trailingContentIsPresented: Bool = false
```

```swift
Button { ...action } label: { ...views }
.swipeActions(leadingActions: [
    .init(title: "Just", color: .darkBlue, action: {})
], trailingActions: [
    .init(title: "Hello", color: .darkBlue, action: {}),
    .init(title:  "World", color: .darkBlueSecondary, action: {}),
    .init(title:  "!", color: .darkBlueTertiary, action: {})
],
    viewConfig: .init(leadingFullSwipeIsEnabled: false,
                      trailingFullSwipeIsEnabled: false,
                      actionWidth: 100,
                      font: .headline),
    leadingContentIsPresented: $leadingContentIsPresented,
    trailingContentIsPresented: $trailingContentIsPresented)
```
<img src= "https://raw.githubusercontent.com/Rayllienstery/TMMediaStorage/main/TMSwipeActions/Promo_4.png" width="512" >

## License
<br />
Package released under the Apache 2.0 license, check the LICENSE file for more info.
