import Foundation

import Dice
import Gardener
import KeychainTypes
import Transmission
import TransmissionAsync

public struct Nametag
{
    static let challengeSize: Int = 64
    static let expectedPublicKeySize: Int = 65
    static let expectedSignatureSize: Int = 64

    static public func check(challenge: Data, clientPublicKey: PublicKey, signature: Signature) throws
    {
        guard clientPublicKey.isValidSignature(signature, for: challenge) else
        {
            throw NametagError.verificationFailed
        }
    }

    static public func checkLive(connection: Transmission.Connection) throws -> PublicKey
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
    
    static public func checkLive(connection: AsyncConnection) async throws -> PublicKey
    {
        print("🔖 checkLive async called. Attempting to readSize(\(Nametag.expectedPublicKeySize)")
        let clientPublicKeyData = try await connection.readSize(Nametag.expectedPublicKeySize)
        print("🔖 checkLive async read \(clientPublicKeyData.count) bytes")
        
        let clientPublicKey = try PublicKey(type: KeyType.P256Signing, data: clientPublicKeyData)
        let challenge = Data(randomWithLength: Nametag.challengeSize)
        
        print("🔖 checkLive async writing \(challenge.count) bytes")
        try await connection.write(challenge)
        print("🔖 checkLive async wrote \(challenge.count) bytes")
        
        print("🔖 checkLive async reading \(Nametag.expectedSignatureSize) bytes")
        let signatureData = try await connection.readSize(Nametag.expectedSignatureSize)
        print("🔖 checkLive async read \(Nametag.expectedSignatureSize) bytes")
        
        let signature = try Signature(type: SignatureType.P256, data: signatureData)
        try self.check(challenge: challenge, clientPublicKey: clientPublicKey, signature: signature)
        
        print("🔖 checkLive async returning a client public key.")
        return clientPublicKey
    }

    let privateKey: PrivateKey
    public let publicKey: PublicKey

    public var data: Data?
    {
        return self.publicKey.data
    }

    public init?(keychain: KeychainProtocol)
    {
        guard let privateSigningKey = keychain.retrieveOrGeneratePrivateKey(label: "Nametag", type: KeyType.P256Signing) else
        {
            return nil
        }
        self.privateKey = privateSigningKey
        self.publicKey = privateSigningKey.publicKey
    }

    public func prove(challenge: Data) throws -> Signature
    {
        return try self.privateKey.signature(for: challenge)
    }

    public func proveLive(connection: Transmission.Connection) throws
    {
        guard let publicKeyData = self.publicKey.data else
        {
            throw NametagError.nilPublicKey
        }

        guard publicKeyData.count == Nametag.expectedPublicKeySize else
        {
            throw NametagError.publicKeyWrongSize(receivedSize: publicKeyData.count, expectedSize: Nametag.expectedPublicKeySize)
        }

        guard connection.write(data: publicKeyData) else
        {
            throw NametagError.writeFailed
        }

        guard let challenge = connection.read(size: Nametag.challengeSize) else
        {
            throw NametagError.noChallengeReceived
        }

        let result = try self.prove(challenge: challenge)
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
    
    public func proveLive(connection: AsyncConnection) async throws
    {
        print("🔖 proveLive async called.")
        
        guard let publicKeyData = self.publicKey.data else
        {
            throw NametagError.nilPublicKey
        }

        guard publicKeyData.count == Nametag.expectedPublicKeySize else
        {
            throw NametagError.publicKeyWrongSize(receivedSize: publicKeyData.count, expectedSize: Nametag.expectedPublicKeySize)
        }
        
        print("🔖 proveLive async writing \(publicKeyData.count) bytes.")
        try await connection.write(publicKeyData)
        print("🔖 proveLive async wrote \(publicKeyData.count) bytes.")
        
        print("🔖 proveLive async reading \(Nametag.challengeSize) bytes.")
        let challenge = try await connection.readSize(Nametag.challengeSize)
        print("🔖 proveLive async read \(challenge.count) bytes.")
        
        let result = try self.prove(challenge: challenge)
        print("🔖 proveLive prove result: \(result).")
        let resultData = result.data

        guard resultData.count == Nametag.expectedSignatureSize else
        {
            throw NametagError.challengeResultWrongSize
        }
        
        print("🔖 proveLive async writing \(resultData.count) bytes.")
        try await connection.write(resultData)
        print("🔖 proveLive async wrote \(resultData.count) bytes. Finished!")
    }

    public func endorse(digest: Digest) throws -> Signature
    {
        return try self.privateKey.signature(for: digest)
    }

    public func endorse(data: Data) throws -> Signature
    {
        return try self.privateKey.signature(for: data)
    }

    public func endorse<T>(object: T) throws -> EndorsedTypedDocument<T> where T: Codable
    {
        return try EndorsedTypedDocument(encodable: object, privateKey: self.privateKey)
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
    case publicKeyWrongSize(receivedSize: Int, expectedSize: Int)
    case verificationFailed
    case noPublicKeyReceived
    case noSignatureReceived
    
    public var description: String
    {
        switch self {
            case .noChallengeReceived:
                return "No challenge was received."
            case .challengeResultWrongSize:
                return "Challenge result was the wrong size."
            case .writeFailed:
                return "Write failed."
            case .nilPublicKey:
                return "The public key cannot be nil."
            case .publicKeyWrongSize(let receivedSize, let expectedSize):
                return "Received a public key of \(receivedSize) bytes, expected \(expectedSize) bytes."
            case .verificationFailed:
                return "The verification failed."
            case .noPublicKeyReceived:
                return "A public key was not received."
            case .noSignatureReceived:
                return "A signature was not received."
        }
    }
}
