---
title: Optional assignment in Swift
tags: swift, programming-languages
description: Proposed optional assignment operator in Swift
---

In [Swift](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/), given a variable `x` of type `Optional<T>`, how can guarantee it is not `nil`? You can force the unwrapping, but this may result in a runtime error. What if we could set `x` to some default value? We can manually, but this can be cumbersome to do often, so let's make an operator! This is a good chance to learn about Swift's [optionals](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/OptionalChaining.html#//apple_ref/doc/uid/TP40014097-CH21-XID_312), [generics](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html#//apple_ref/doc/uid/TP40014097-CH26-XID_234), [custom operators](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/AdvancedOperators.html#//apple_ref/doc/uid/TP40014097-CH27-XID_48), and [in-out parameters](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Functions.html#//apple_ref/doc/uid/TP40014097-CH10-XID_226).[^1]


~~~ JavaScript
operator infix ~= {}

@assignment func ~=<T>(inout lhs: Optional<T>, rhs: T) {
    if lhs == nil {
        lhs = rhs
    }
}

var x: String? = "nil"
var y: String? = nil

x ~= "Test"
y ~= "Test"

x  // "nil"
y  // "Test" 
~~~

I'd prefer `?=` but `?` is not allowed in custom operators.

[^1]: I apologize for the poor syntax highlighting!
