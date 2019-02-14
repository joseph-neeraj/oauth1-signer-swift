# oauth1-signer-swift

[![](https://travis-ci.org/Mastercard/oauth1-signer-swift.svg?branch=master)](https://travis-ci.org/Mastercard/oauth1-signer-swift)
[![](https://sonarcloud.io/api/project_badges/measure?project=Mastercard_oauth1-signer-swift&metric=alert_status)](https://sonarcloud.io/dashboard?id=Mastercard_oauth1-signer-swift) 
[![](https://img.shields.io/cocoapods/v/OAuth1Signer.svg?style=flat)](https://cocoapods.org/pods/OAuth1Signer)
[![](https://img.shields.io/badge/license-MIT-yellow.svg)](https://github.com/Mastercard/oauth1-signer-swift/blob/master/LICENSE)

## Overview

Zero dependency Swift library for generating a Mastercard API compliant OAuth signature.

## Usage

### Prerequisites

Before using this library, you will need to set up a project and key in the [Mastercard Developers Portal](https://developer.mastercard.com).

The two key pieces of information you will need are:

- Consumer key
- Private key matching the public key uploaded to Mastercard Developer Portal

### Install

`MastercardOAuth` is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'MastercardOAuth'

```
You can then import the framework from Swift:
```swift
import MastercardOAuth
```

*Note: Use of this library as a pod requires Xcode 10 or later.*

### Creating a valid OAuth Authorization header string

The method that does all the heavy lifting is `OAuth.authorizationHeader()`. You can call into it directly and as long as you provide the correct parameters, it will return a string that you can add into your HTTP request's `Authorization` header.

### Example

To run the example project, first clone the repo and then `pod install` from the Example directory.

Example usage:

```swift
  let uri = URL(string: "https://sandbox.api.mastercard.com/service")!
  let method = "GET"
  let examplePayload: [String: String] = ["languageId": 1,
                                          "geographicId": 0]
  let payloadJSON = (try? JSONSerialization.data(withJSONObject: examplePayload, options: [])) ?? Data()
  let payloadString = String(data: payloadJSON, encoding: .utf8)
  
  let consumerKey = "<insert consumer key from developer portal>"
  let signingKey = "<initialize private key matching the consumer key>"

  let header = try? OAuth.authorizationHeader(forUri: uri, method: method, payload: payloadString, consumerKey: consumerKey, signingPrivateKey: myPrivateKey)

```

You can use the utility `KeyProvider.swift` to create a `SecKey` object representing your developer private key. Simply pass in the bundle path containing your `Certificate.p12` to:

```KeyProvider.loadPrivateKey(fromPath certificatePath: String, keyPassword: String) -> SecKey?```

## Author

Luke Reichold, luke@reikam.com

## License

MastercardOAuth is available under the MIT license. See the LICENSE file for more info.
