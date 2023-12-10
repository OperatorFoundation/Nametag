//
//  TransmissionNametagClientConnection.swift
//
//
//  Created by Dr. Brandon Wiley on 10/4/22.
//

import Foundation
import Logging

import Chord
import Datable
import KeychainTypes
import Nametag
import Net
import ShadowSwift
import Straw
import SwiftHexTools
import TransmissionAsync

// A connection to a server
public class AsyncNametagClientConnection: AsyncAuthenticatingConnection
{
    
    public var publicKey: PublicKey
    {
        return self.protectedPublicKey
    }

    public var network: AsyncConnection
    {
        return self.protectedConnection
    }

    let protectedConnection: AsyncConnection
    let protectedPublicKey: PublicKey

    let logger: Logger
    let nametag: Nametag
    let straw = Straw()
    let lock = DispatchSemaphore(value: 1)

    var open = true

    public convenience init(config: ShadowConfig.ShadowClientConfig, keychain: any KeychainProtocol, logger: Logger) async throws
    {
        guard let nametag = Nametag(keychain: keychain) else
        {
            throw NametagClientConnectionError.nametagInitFailed
        }
        
        let protectedConnection = try await AsyncDarkstarClientConnection(config.serverIP, Int(config.serverPort), config, logger)

        try await self.init(protectedConnection, nametag, logger)
    }

    public required init(_ base: AsyncConnection, _ keychain: any KeychainProtocol, _ logger: Logger) async throws
    {
        guard let nametag = Nametag(keychain: keychain) else
        {
            throw NametagClientConnectionError.nametagInitFailed
        }

        self.protectedConnection = base
        self.protectedPublicKey = nametag.publicKey

        self.nametag = nametag
        self.logger = logger

        try await self.nametag.proveLive(connection: self.network)
    }

    public required init(_ base: AsyncConnection, _ nametag: Nametag, _ logger: Logger) async throws
    {
        self.protectedConnection = base
        self.protectedPublicKey = nametag.publicKey

        self.nametag = nametag
        self.logger = logger

        try await self.nametag.proveLive(connection: self.protectedConnection)
    }
}

public enum NametagClientConnectionError: Error
{
    case readFailed
    case couldNotLoadDocument
    case keyEncodingFailed
    case nametagInitFailed
    case connectionFailed
    case serverSigningKeyMismatch
    case writeFailed
    case closed
    case badPort(String)
}
