# oauth1-signer-swift

[![](https://travis-ci.org/Mastercard/oauth1-signer-swift.svg?branch=master)](https://travis-ci.org/Mastercard/oauth1-signer-swift)
[![](https://sonarcloud.io/api/project_badges/measure?project=Mastercard_oauth1-signer-swift&metric=alert_status)](https://sonarcloud.io/dashboard?id=Mastercard_oauth1-signer-swift) 
[![](https://img.shields.io/cocoapods/v/OAuth1Signer.svg?style=flat)](https://cocoapods.org/pods/OAuth1Signer)
[![](https://img.shields.io/badge/license-MIT-yellow.svg)](https://github.com/Mastercard/oauth1-signer-swift/blob/master/LICENSE)

## Table of Contents
- [Overview](#overview)
    * [Compatibility](#compatibility)
    * [References](#references)
- [Usage](#usage)
    * [Prerequisites](#prerequisites)
    * [Adding the Library to Your Project](#adding-the-library-to-your-project)
    * [Loading the Signing Key](#loading-the-signing-key) 
    * [Creating the OAuth Authorization Header](#creating-the-oauth-authorization-header)
    * [Example](#example)


## Overview <a name="overview"></a>

Zero dependency Swift library for generating a Mastercard API compliant OAuth signature.

### Compatibility <a name="compatibility"></a>
Swift 4.2

### References <a name="references"></a>
* [OAuth 1.0a specification](https://tools.ietf.org/html/rfc5849)

## Usage <a name="usage"></a>

### Prerequisites <a name="prerequisites"></a>

Before using this library, you will need to set up a project and key in the [Mastercard Developers Portal](https://developer.mastercard.com).

As part of this set up, you'll receive credentials for your app:
* A consumer key (displayed on the Mastercard Developer Portal)
* A private request signing key (matching the public certificate displayed on the Mastercard Developer Portal)

### Adding the Library to Your Project <a name="adding-the-library-to-your-project"></a>

`MastercardOAuth1Signer` is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'MastercardOAuth1Signer'
```
You can then import the framework from Swift:
```swift
import MastercardOAuth1Signer
```

*Note: Use of this library as a pod requires Xcode 10 or later.*

### Loading the Signing Key <a name="loading-the-signing-key"></a>

You can use the utility `KeyProvider.swift` to create a `SecKey` object representing your developer private key. Simply pass in the bundle path containing your `Certificate.p12` and Password:

```swift
    let signingKey = KeyProvider.loadPrivateKey(fromPath: certificatePath, keyPassword: "<<PASSWORD>>")!
```

### Creating the OAuth Authorization Header <a name="creating-the-oauth-authorization-header"></a>

The method that does all the heavy lifting is `OAuth.authorizationHeader()`. You can call into it directly and as long as you provide the correct parameters, it will return a string that you can add into your HTTP request's `Authorization` header.

```swift
let header = try? OAuth.authorizationHeader(forUri: uri, method: method, payload: payloadString, consumerKey: consumerKey, signingPrivateKey: signingKey)
```

### Example <a name="example"></a>

To run the example project, first clone the repo and then `pod install` from the project directory.

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
  
  let headers: HTTPHeaders = ["Authorization": header!,
                                     "Accept": "application/json",
                                    "Referer": "api.mastercard.com"]
```

## Author

Luke Reichold, luke@reikam.com, Mastercard

## License

MastercardOAuth1Signer is available under the MIT license. See the LICENSE file for more info.
