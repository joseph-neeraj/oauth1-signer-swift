# oauth1-signer-swift

[![](https://github.com/Mastercard/oauth1-signer-swift/workflows/Build%20&%20Test/badge.svg)](https://github.com/Mastercard/oauth1-signer-swift/actions?query=workflow%3A%22Build+%26+Test%22)
[![](https://sonarcloud.io/api/project_badges/measure?project=Mastercard_oauth1-signer-swift&metric=alert_status)](https://sonarcloud.io/dashboard?id=Mastercard_oauth1-signer-swift)
[![](https://github.com/Mastercard/oauth1-signer-swift/workflows/broken%20links%3F/badge.svg)](https://github.com/Mastercard/oauth1-signer-swift/actions?query=workflow%3A%22broken+links%3F%22)
[![](https://img.shields.io/cocoapods/v/MastercardOAuth1Signer.svg?style=flat&color=blue)](https://cocoapods.org/pods/MastercardOAuth1Signer)
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
    * [Integrating with OpenAPI Generator API Client Libraries](#integrating-with-openapi-generator-api-client-libraries)

## Overview <a name="overview"></a>

Zero dependency library for generating a Mastercard API compliant OAuth signature.

### Compatibility <a name="compatibility"></a>
Swift 4.2

### References <a name="references"></a>
* [OAuth 1.0a specification](https://tools.ietf.org/html/rfc5849)
* [Body hash extension for non application/x-www-form-urlencoded payloads](https://tools.ietf.org/id/draft-eaton-oauth-bodyhash-00.html)

## Usage <a name="usage"></a>

### Prerequisites <a name="prerequisites"></a>

Before using this library, you will need to set up a project in the [Mastercard Developers Portal](https://developer.mastercard.com). 

As part of this set up, you'll receive credentials for your app:
* A consumer key (displayed on the Mastercard Developer Portal)
* A private request signing key (matching the public certificate displayed on the Mastercard Developer Portal)

### Adding the Library to Your Project <a name="adding-the-library-to-your-project"></a>

`MastercardOAuth1Signer` is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```
pod 'MastercardOAuth1Signer'
```

You can then import the framework from Swift:
```swift
import MastercardOAuth1Signer
```

*Note: Use of this library as a pod requires Xcode 10 or later.*

### Loading the Signing Key <a name="loading-the-signing-key"></a>

You can use the utility `KeyProvider.swift` to create a `SecKey` object representing your developer private key. 
For that, simply pass in a bundle path for your PKCS#12 key store along with its password:

```swift
let signingKey = KeyProvider.loadPrivateKey(fromPath: certificatePath, keyPassword: "<<PASSWORD>>")!
```

### Creating the OAuth Authorization Header <a name="creating-the-oauth-authorization-header"></a>

#### OAuth.authorizationHeader <a name="oauth-authorizationheader"></a>

The method that does all the heavy lifting is `OAuth.authorizationHeader()`. You can call into it directly and as long as you provide the correct parameters, it will return a string that you can add into your request's `Authorization` header.

```swift
let header = try? OAuth.authorizationHeader(forUri: uri, method: method, payload: payloadString, consumerKey: consumerKey, signingPrivateKey: signingKey)
```

#### Example <a name="example"></a>

To run the example project, first clone this repo and then `pod install` from the project directory.

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
### Integrating with OpenAPI Generator API Client Libraries <a name="integrating-with-openapi-generator-api-client-libraries"></a>

[OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator) generates API client libraries from [OpenAPI Specs](https://github.com/OAI/OpenAPI-Specification). 
It provides generators and library templates for supporting multiple languages and frameworks.

To use MastercardOAuth1Signer with a generated client library in Swift 5, follow the below steps:

1. Create a new class to which generates and adds an auth header in the URLRequest.
```swift
import MastercardOAuth1Signer

class RequestAuthDecorator: NSObject {
    static func addAuthHeaders(request: URLRequest) -> URLRequest {
        var urlRequest = request
        let certificatePath = Bundle(for: RequestAuthDecorator.self).path(forResource: "<<FILENAME>>", ofType: "p12")
        let signingKey = KeyProvider.loadPrivateKey(fromPath: certificatePath!, keyPassword: "<<PASSWORD>>")!
        let consumerKey = "CONSUMER_KEY"
        var payloadString :String? = nil
        if urlRequest.httpBody != nil
        {
            payloadString = String.init(data: urlRequest.httpBody!, encoding: .utf8)
        }
        let header = try? OAuth.authorizationHeader(forUri: urlRequest.url!, method: urlRequest.httpMethod!, payload: payloadString, consumerKey: consumerKey, signingPrivateKey: signingKey)
        urlRequest.setValue(header!, forHTTPHeaderField: "Authorization")
        return urlRequest;
    }
}
```
2. Create a subclass of 'URLSessionRequestBuilder' & 'URLSessionDecodableRequestBuilder' and override the 'createUrlRequest' method in both classes to insert the auth header in the request.

```swift
class CustomURLSessionRequestBuilder<T>: URLSessionRequestBuilder<T> {
    
    override func createURLRequest(urlSession: URLSession, method: HTTPMethod, encoding: ParameterEncoding, headers: [String : String]) throws -> URLRequest {
        let request: URLRequest = try super.createURLRequest(urlSession: urlSession, method: method, encoding: encoding, headers: headers);
        let requestWithAuthHeader = RequestAuthDecorator.addAuthHeaders(request: request);
        return requestWithAuthHeader;
    }
  
}

class CustomURLSessionDecodableRequestBuilder<T:Decodable>: URLSessionDecodableRequestBuilder<T> {
    
    override func createURLRequest(urlSession: URLSession, method: HTTPMethod, encoding: ParameterEncoding, headers: [String : String]) throws -> URLRequest {
        let request: URLRequest = try super.createURLRequest(urlSession: urlSession, method: method, encoding: encoding, headers: headers);
        let requestWithAuthHeader = RequestAuthDecorator.addAuthHeaders(request: request);
        return requestWithAuthHeader;
    }

}

```
3. Create a subclass of 'RequestBuilderFactory' to override 'getBuilder' & 'getNonDecodableBuilder'. Make these methods to return above created 'CustomURLSessionRequestBuilder' & 'CustomURLSessionDecodableRequestBuilder' respectively.
```swift
class CustomURLSessionRequestBuilderFactory: RequestBuilderFactory {
    func getNonDecodableBuilder<T>() -> RequestBuilder<T>.Type {
        return CustomURLSessionRequestBuilder<T>.self
    }

    func getBuilder<T:Decodable>() -> RequestBuilder<T>.Type {
        return CustomURLSessionDecodableRequestBuilder<T>.self
    }
}
```
4. Open the generated `APIs.swift` and assign the `CustomURLSessionRequestBuilderFactory` to requestBuilderFactory.
```swift
    public static var requestBuilderFactory: RequestBuilderFactory = CustomURLSessionRequestBuilderFactory()

```

See also:
* [OpenAPI Generator (executable)](https://mvnrepository.com/artifact/org.openapitools/openapi-generator-cli)
* [CONFIG OPTIONS for swift4](https://github.com/OpenAPITools/openapi-generator/blob/master/docs/generators/swift4-deprecated.md)

## Authors

* Luke Reichold, luke@reikam.com
* Mastercard
