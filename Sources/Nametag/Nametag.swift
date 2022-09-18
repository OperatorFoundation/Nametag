import Foundation

import Keychain
import Transmission

public struct Nametag
{
    static let challengeSize: Int = 64
    static let expectedPublicKeySize: Int = 32
    static let expectedSignatureSize: Int = 64

    let privateKey: PrivateKey
    let publicKey: PublicKey

    public var data: Data?
    {
        return self.publicKey.data
    }

    public init?()
    {
        let keychain = Keychain()
        guard let privateSigningKey = keychain.retrieveOrGeneratePrivateKey(label: "Nametag", type: KeyType.P256Signing) else
        {
            return nil
        }
        self.privateKey = privateSigningKey
        self.publicKey = privateSigningKey.publicKey
    }

    public func prove(challenage: Data) throws -> Signature
    {
        return try self.privateKey.signature(for: challenage)
    }

    public func proveLive(connection: Transmission.Connection) throws
    {
        guard let publicKeyData = self.publicKey.data else
        {
            throw NametagError.nilPublicKey
        }

        guard publicKeyData.count == Nametag.expectedPublicKeySize else
        {
            throw NametagError.publicKeyWrongSize
        }

        guard connection.write(data: publicKeyData) else
        {
            throw NametagError.writeFailed
        }

        guard let challenge = connection.read(size: Nametag.challengeSize) else
        {
            throw NametagError.noChallengeReceived
        }

        let result = try self.prove(challenage: challenge)
        let resultData = result.data

        guard resultData.count == Nametag.expectedSignatureSize else
        {
            throw NametagError.challengeResultWrongSize
        }

        guard connection.write(data: resultData) else
        {
            throw NametagError.writeFailed
        }
    }

    public func endorse(digest: Digest) throws -> Signature
    {
        return try self.privateKey.signature(for: digest)
    }

    public func endorse(data: Data) throws -> Signature
    {
        return try self.privateKey.signature(for: data)
    }

    public func verify(signature: Signature, digest: Digest) -> Bool
    {
        return self.publicKey.isValidSignature(signature, for: digest)
    }

    public func verify(signature: Signature, data: Data) -> Bool
    {
        return self.publicKey.isValidSignature(signature, for: data)
    }
}

public enum NametagError: Error
{
    case noChallengeReceived
    case challengeResultWrongSize
    case writeFailed
    case nilPublicKey
    case publicKeyWrongSize
}
