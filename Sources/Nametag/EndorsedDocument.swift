//
//  EndorsedDocument.swift
//  
//
//  Created by Dr. Brandon Wiley on 9/18/22.
//

import Foundation

import Datable
import Keychain

public class EndorsedDocument: Codable
{
    static public func endorse(data: Data, privateKey: PrivateKey) throws -> EndorsedDocument
    {
        return try EndorsedDocument(data: data, privateKey: privateKey)
    }

    static public func endorse<T>(dataProtocol: T, privateKey: PrivateKey) throws -> EndorsedDocument where T: DataProtocol
    {
        let data = Data(dataProtocol)
        return try EndorsedDocument(data: data, privateKey: privateKey)
    }

    static public func endorse<T>(encodable: T, privateKey: PrivateKey) throws -> EndorsedDocument where T: Encodable
    {
        let encoder = JSONEncoder()
        let data = try encoder.encode(encodable)
        return try EndorsedDocument(data: data, privateKey: privateKey)
    }

    static public func endorse<T>(datable: T, privateKey: PrivateKey) throws -> EndorsedDocument where T: Datable
    {
        let data = datable.data
        return try EndorsedDocument(data: data, privateKey: privateKey)
    }

    static public func endorse<T>(maybeDatable: T, privateKey: PrivateKey) throws -> EndorsedDocument where T: MaybeDatable
    {
        let data = maybeDatable.data
        return try EndorsedDocument(data: data, privateKey: privateKey)
    }

    public let data: Data
    public let signed: SignaturePage

    public init(data: Data, signed: SignaturePage) throws
    {
        self.data = data
        self.signed = signed

        guard self.signed.isValidSignature(for: data) else
        {
            throw EndorsedDocumentError.signatureVerificationFailed
        }
    }

    public init(data: Data, privateKey: PrivateKey) throws
    {
        self.data = data

        let signature = try privateKey.signature(for: data)
        let publicKey = privateKey.publicKey
        self.signed = try SignaturePage(signature: signature, publicKey: publicKey)
    }

    public func decode<T>() throws -> T where T: Decodable
    {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: self.data)
    }

    public func decode<T>() -> T where T: Datable
    {
        return T.init(data: self.data)
    }

    public func decode<T>() -> T? where T: MaybeDatable
    {
        return T.init(data: self.data)
    }
}

public enum EndorsedDocumentError: Error
{
    case signatureVerificationFailed
}
