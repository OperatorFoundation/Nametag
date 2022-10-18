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
        guard self.signed.isValidSignature(for: self.data) else
        {
            throw EndorsedDocumentError.signatureVerificationFailed
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: self.data)
    }

    public func decode<T>() throws -> T where T: Datable
    {
        guard self.signed.isValidSignature(for: self.data) else
        {
            throw EndorsedDocumentError.signatureVerificationFailed
        }

        return T.init(data: self.data)
    }

    public func decode<T>() throws -> T? where T: MaybeDatable
    {
        guard self.signed.isValidSignature(for: self.data) else
        {
            throw EndorsedDocumentError.signatureVerificationFailed
        }

        return T.init(data: self.data)
    }
}

public class EndorsedTypedDocument<T>: Codable, Equatable, MaybeDatable where T: Codable, T: Equatable
{
    public static func == (lhs: EndorsedTypedDocument<T>, rhs: EndorsedTypedDocument<T>) -> Bool
    {
        return (lhs.object == rhs.object) && (lhs.signed == rhs.signed)
    }

    public let object: T
    public let signed: SignaturePage

    public var data: Data
    {
        do
        {
            let encoder = JSONEncoder()
            return try encoder.encode(self)
        }
        catch
        {
            return Data()
        }
    }

    public required convenience init?(data: Data)
    {
        do
        {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Self.self, from: data)

            try self.init(object: decoded.object, signed: decoded.signed)
        }
        catch
        {
            return nil
        }
    }

    public init(encodable: T, privateKey: PrivateKey) throws
    {
        self.object = encodable

        let encoder = JSONEncoder()
        let data = try encoder.encode(encodable)
        let signature = try privateKey.signature(for: data)
        let publicKey = privateKey.publicKey
        self.signed = try SignaturePage(signature: signature, publicKey: publicKey)
    }

    init(object: T, signed: SignaturePage) throws
    {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)

        guard signed.isValidSignature(for: data) else
        {
            throw EndorsedDocumentError.signatureVerificationFailed
        }

        self.object = object
        self.signed = signed
    }
}

public enum EndorsedDocumentError: Error
{
    case signatureVerificationFailed
}
