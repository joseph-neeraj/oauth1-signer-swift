//
//  OAuth.swift
//  OAuth1Signer
//
//  Created by Luke Reichold on 12/2/18.
//  Copyright © 2018 Reikam Labs. All rights reserved.
//

import Foundation
import Security
import CommonCrypto

typealias AuthorizationHeader = String

struct OAuth {
    static let SHA_BITS = "256"
    
    static func getAuthorizationHeader(forUri uri: URL,
                                       method: String,
                                       payload: String?,
                                       consumerKey: String,
                                       signingKey: String) throws -> AuthorizationHeader {
        
        let baseUri = uri.baseURL?.absoluteString.lowercased() ?? ""
        let queryParams = uri.queryParams()
        var authParams = oauthParams(withKey: consumerKey, payload: payload)
        let sbs = signatureBaseString(httpMethod: method, baseUri: baseUri, paramString: uri.query ?? "")
        
        // Signature
        let signature = signSignatureBaseString(sbs: sbs, signingKey: signingKey)
        let encodedSignature = signature //.addingPercentEncoding(withAllowedCharacters: .)
        authParams["oauth_signature"] = encodedSignature
        
        return authorizationString(oauthParams: authParams)
    }
}

extension OAuth {
    
    static func signSignatureBaseString(sbs: String, signingKey: String) -> String {
        return ""
    }
    
    static func authorizationString(oauthParams: [String: String]) -> String {
        var header = "OAuth "
        for (key, value) in oauthParams {
            header.append("\(key)=\"\(value)\",")
        }
        return String(header.dropLast())
    }
    
    static func signatureBaseString(httpMethod: String, baseUri: String, paramString: String) -> String {
        let escapedBaseUri = baseUri.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let escapedParams = paramString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return httpMethod.uppercased()
        + "&"
        + escapedBaseUri
        + "&"
        + escapedParams
    }
    
    static func currentUnixTimestamp() -> String {
        return String(Date().timeIntervalSince1970)
    }
    
    static func nonce() -> String {
        let bytesCount = 8
        var randomBytes = [UInt8](repeating: 0, count: bytesCount)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytesCount, &randomBytes)

        let validChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return randomBytes.map { randomByte in
            return validChars[Int(randomByte % UInt8(validChars.count))]
        }.joined()
    }
    
    static func oauthParams(withKey consumerKey: String, payload: String?) -> [String: String] {
        var oauthParams = [String: String]()
        if payload != nil {
            oauthParams["oauth_body_hash"] = payload?.sha256() ?? ""
        }
        oauthParams["oauth_consumer_key"] = consumerKey
        oauthParams["oauth_nonce"] = nonce()
        oauthParams["oauth_signature_method"] = "RSA-SHA256"
        oauthParams["oauth_timestamp"] = currentUnixTimestamp()
        oauthParams["oauth_version"] = "1.0"
        return oauthParams
    }
    
    static func getBodyHash() -> String {
        return ""
    }
}

extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    func sha256() -> String? {
        guard
            let data = data(using: String.Encoding.utf8),
            let shaData = data.sha256()
            else { return nil }
        let rc = shaData.base64EncodedString(options: [])
        return rc
    }
    
}

extension String: Error {}

extension Data {
    func sha256() -> Data? {
        guard let res = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH)) else { return nil }
        CC_SHA256((self as NSData).bytes, CC_LONG(self.count), res.mutableBytes.assumingMemoryBound(to: UInt8.self))
        return res as Data
    }
}

extension URL {
    func queryParams() -> [URLQueryItem]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        return components.queryItems?.sorted()
        // TODO: values for parameters with the same name are added into a list ?? Is this ever necessary?
        // TODO: components.percentEncodedQueryItems instead ??
    }
}

extension URLQueryItem: Comparable {
    public static func < (lhs: URLQueryItem, rhs: URLQueryItem) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
}
