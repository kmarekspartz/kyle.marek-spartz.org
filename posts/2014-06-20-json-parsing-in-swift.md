---
title: JSON Parsing in Swift
tags: swift, web-dev, programming-languages
description: Is JSON parsing in Swift really that difficult?
---

This past week there was a [post](https://medium.com/@owensd/swift-json-parsing-716ea9be1c5b) criticizing Swift's static typing as limiting when it comes to "parsing" JSON. They weren't really parsing JSON, rather just extracting values from a specific point in the structure, but the point remains: Swift's static typing makes it difficult to extract values from a dynamic structure. The [redditors](http://www.reddit.com/r/swift/comments/28g72k/swift_json_parsing_help_me_with_the_errors_of_my/) didn't have much to say, except for [two](http://www.reddit.com/r/swift/comments/28g72k/swift_json_parsing_help_me_with_the_errors_of_my/ciaop9l) [voices](http://www.reddit.com/r/swift/comments/28g72k/swift_json_parsing_help_me_with_the_errors_of_my/ciapp9h) of reason, who weren't understood. Most of the redditors seemed to insist that JSON is fully schema-less and thus should have `AnyObject` as its representation, to keep things fully dynamic.

But JSON isn't really as dynamic as they are claiming. Since they used `AnyObject` to represent a JSON object, this caused their frustration with [downcasting](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/TypeCasting.html#//apple_ref/doc/uid/TP40014097-CH22-XID_446). Instead, let's make a library using static typing to help us out, by building an [algebraic data type](https://en.wikipedia.org/wiki/Algebraic_data_type) representing all possible JSON objects. According to [JSON.org](http://json.org/), we have *values* which can be *objects*, *arrays*, *strings*, *numbers*, *booleans*, or `null`. Let's convert the syntax diagrams into an ADT as follows:

~~~ JavaScript
enum JSONValue {
    case JSONObject(Dictionary<String,JSONValue>)
    case JSONArray(List<JSONValue>)
    case JSONString(String)
    case JSONNumber(Double)
    case JSONBoolean(Bool)
    case JSONNull
}

extension JSONValue: Collection {
    // Provide lookup methods for JSONObject and JSONArray.
    ...
}

extension JSONValue: Printable {
    // Prints as JSON.
    // This might not be the best way to do it:
    // See Haskell's `Pretty` and `Show`.
    let description: String {
    get {
        switch self {
        ...
        case let .JSONString(s): return "\"" + s "\""
        ...
        }
    }
    }
}
~~~

And that's it![^1]

This makes the operation they implemented as follows:

~~~ JavaScript
for item in json["blogs"]?["blog"] {
    let id = blog[“id”]
    let name = blog[“name”]
    let needspassword = blog[“needspassword”]
    let url = blog[“url”]

    println(“Blog ID: \(id)”)
    println(“Blog Name: \(name)”)
    println(“Blog Needs Password: \(needspassword)”)
    println(“Blog URL: \(url)”)
}
~~~

That's a lot easier, once a proper JSON library is implemented, anyway. [Swiftz](https://github.com/typelift/Swiftz/) has the start of one, similar in style to what I'm proposing here.



[^1]: Or close to it anyway. I'm simplifying here. See [Swiftz](https://github.com/typelift/Swiftz/) for a more complete JSON library.
