//
//  Extensions.swift
//  Alamofire
//
//  Created by Conver on 10/7/2019.
//

import CommonCrypto
import SwifterSwift
import UIKit

public func debugOnly(_ action: () -> Void) {
    assert(
        {
            action()
            return true
        }()
    )
}

public protocol URLStringConvertible {
    var url: URL? { get }
    var string: String { get }
}

extension String: URLStringConvertible {
    public var url: URL? {
        return URL(string: self)
    }

    public var string: String {
        return self
    }
}

public extension String {
    func sha1() -> String {
        let data = Data(utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined()
    }
}

public enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5: result = kCCHmacAlgMD5
        case .SHA1: result = kCCHmacAlgSHA1
        case .SHA224: result = kCCHmacAlgSHA224
        case .SHA256: result = kCCHmacAlgSHA256
        case .SHA384: result = kCCHmacAlgSHA384
        case .SHA512: result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }

    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5: result = CC_MD5_DIGEST_LENGTH
        case .SHA1: result = CC_SHA1_DIGEST_LENGTH
        case .SHA224: result = CC_SHA224_DIGEST_LENGTH
        case .SHA256: result = CC_SHA256_DIGEST_LENGTH
        case .SHA384: result = CC_SHA384_DIGEST_LENGTH
        case .SHA512: result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}

extension String {
    var md5:String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02X", $1) }
    }
}

public extension String {
    func hmac(algorithm: CryptoAlgorithm, key: String) -> String {
        let str = cString(using: String.Encoding.utf8)
        let strLen = Int(lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))

        CCHmac(algorithm.HMACAlgorithm, keyStr!, keyLen, str!, strLen, result)

        let digest = stringFromResult(result: result, length: digestLen)

        result.deallocate()

        return digest
    }

    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0 ..< length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash).lowercased()
    }
}
