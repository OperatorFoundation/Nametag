import Foundation

import Dice
import Gardener
import Keychain
import Transmission

public struct Nametag
{
    static let challengeSize: Int = 64
    static let expectedPublicKeySize: Int = 32
    static let expectedSignatureSize: Int = 64

    let privateKey: PrivateKey
    public let publicKey: PublicKey

    public var data: Data?
    {
        return self.publicKey.data
    }

    public init?()
    {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        let keychain = Keychain()
        #else
        guard let keychain = Keychain(baseDirectory: File.homeDirectory().appendingPathComponent(".nametag")) else
        {
            return nil
        }
        #endif

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

    public func check(challenge: Data, clientPublicKey: PublicKey, signature: Signature) throws
    {
        guard clientPublicKey.isValidSignature(signature, for: challenge) else
        {
            throw NametagError.verificationFailed
        }
    }

    public func checkLive(connection: Transmission.Connection) throws -> PublicKey
    {
        guard let clientPublicKeyData = connection.read(size: Nametag.expectedPublicKeySize) else
        {
            throw NametagError.noPublicKeyReceived
        }

        let clientPublicKey = try PublicKey(type: KeyType.P256Signing, data: clientPublicKeyData)

        let challenge = Data(randomWithLength: Nametag.challengeSize)
        guard connection.write(data: challenge) else
        {
            throw NametagError.writeFailed
        }

        guard let signatureData = connection.read(size: Nametag.expectedSignatureSize) else
        {
            throw NametagError.noSignatureReceived
        }

        let signature = try Signature(type: SignatureType.P256, data: signatureData)

        try self.check(challenge: challenge, clientPublicKey: clientPublicKey, signature: signature)

        return clientPublicKey
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
    case verificationFailed
    case noPublicKeyReceived
    case noSignatureReceived
}
