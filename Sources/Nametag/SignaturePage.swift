//
//  SignaturePage.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/18/22.
//

import Foundation

import Keychain

public struct SignaturePage: Codable
{
    public let signature: Signature
    public let publicKey: PublicKey

    public init(signature: Signature, publicKey: PublicKey) throws
    {
        self.signature = signature
        self.publicKey = publicKey
    }

    public func isValidSignature(for data: Data) -> Bool
    {
        return self.publicKey.isValidSignature(self.signature, for: data)
    }
}
